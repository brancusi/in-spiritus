class Order < ActiveRecord::Base
  include AASM

  SALES_ORDER_TYPE = 'sales-order'
  PURCHASE_ORDER_TYPE = 'purchase-order'

  after_create :setup_defaults
  after_save :update_fulfillment_structure
  before_destroy :clear_fulfillment_structure

  aasm :order, :column => :xero_state, :skip_validation_on_save => true do
    state :pending, :initial => true
    state :submitted
    state :synced
    state :voided

    event :mark_submitted do
      transitions :from => :pending, :to => :submitted
      transitions :from => :synced, :to => :submitted
    end

    event :mark_synced do
      transitions :from => :synced, :to => :synced
      transitions :from => :submitted, :to => :synced
    end

    # TODO: Is there a way to trap in voided once void state is set?
    # Since we allow direct set, the client may be able to get a model
    # out of voided by resubmitting
    event :void do
      transitions :from => [:pending, :submitted, :synced], :to => :voided
    end
  end

  aasm :notification, :column => :notification_state, :skip_validation_on_save => true do
    state :pending_notification, :initial => true
    state :pending_updated_notification
    state :awaiting_notification
    state :notified
    state :awaiting_updated_notification

    event :mark_pending do
      transitions :from => :awaiting_notification, :to => :pending
      transitions :from => :awaiting_updated_notification, :to => :pending
      transitions :from => :notified, :to => :pending
    end

    event :mark_pending_updated do
      transitions :from => :awaiting_notification, :to => :pending_updated_notification
      transitions :from => :awaiting_updated_notification, :to => :pending_updated_notification
      transitions :from => :notified, :to => :pending_updated_notification
    end

    event :mark_awaiting_notification do
      transitions :from => :pending_notification, :to => :awaiting_notification
    end

    event :mark_notified do
      transitions :from => :awaiting_notification, :to => :notified
      transitions :from => :awaiting_updated_notification, :to => :notified
      transitions :from => :notified, :to => :notified
    end

    event :mark_awaiting_updated_notification do
      transitions :from => :notified, :to => :awaiting_updated_notification
    end
  end

  # State machine settings
  enum xero_state: [ :pending, :submitted, :synced, :voided ]
  enum notification_state: [ :pending_notification, :pending_updated_notification, :awaiting_notification, :notified, :awaiting_updated_notification ]

  belongs_to :location
  has_one :address, through: :location
  has_one :fulfillment
  has_one :route_visit, through: :fulfillment
  has_many :order_items, -> { joins(:item).order('position') }, :dependent => :destroy, autosave: true

  scope :purchase_order, -> { where(order_type:PURCHASE_ORDER_TYPE)}
  scope :sales_order, -> { where(order_type:SALES_ORDER_TYPE)}

  def renderer
    sales_order? ? Pdf::Invoice : Pdf::PurchaseOrder
  end

  def sales_order?
    order_type == SALES_ORDER_TYPE
  end

  def purchase_order?
    !sales_order?
  end

  def has_quantity?
    order_items.any?(&:has_quantity?)
  end

  def has_shipping?
    shipping > 0
  end

  def fulfillment_id=(_value)
     # TODO: Remove once it's fixed
  end

  def fulfillment_id
    fulfillment.id
  end

  def total
    order_items_total = order_items.inject(0) {|acc, cur| acc + cur.total }
    order_items_total + shipping
  end

  def due_date
    delivery_date + location.company.terms
  end

  private
  def setup_defaults
    generate_order_number
    set_shipping
  end

  def generate_order_number
    if order_number.nil?
      prefix = sales_order? ? 'SO' : 'PO'
      new_number = "#{prefix}-#{delivery_date.strftime('%y%m%d')}-#{SecureRandom.hex(2)}"
      update_columns(order_number: new_number)
    end
  end

  def set_shipping
    update_columns(shipping: location.delivery_rate)
  end

  def stale_route_visit?
    Maybe(fulfillment).route_visit.date.fetch(nil) != delivery_date
  end

  def update_fulfillment_structure
    if Maybe(fulfillment).route_visit.present?
      if stale_route_visit?
        fulfillment.route_visit = generate_parent_route_visit
        fulfillment.save
      end
    else
      create_fulfillment_structure
    end
  end

  def generate_parent_route_visit
    RouteVisit.find_or_create_by(date:delivery_date, address:address)
  end

  def create_fulfillment_structure
    credit_note = CreditNote.create(date:delivery_date, location:location)
    stock = Stock.create(location:location)
    pod = Pod.create
    fulfillment = Fulfillment.create(
      route_visit:generate_parent_route_visit,
      order:self,
      pod:pod,
      credit_note: credit_note,
      stock: stock
    )
  end

  def clear_fulfillment_structure
    single_fulfillment_for_route_visit = Maybe(fulfillment).route_visit.fulfillments.size.fetch(1) == 1

    Maybe(fulfillment).route_visit._.destroy if single_fulfillment_for_route_visit
    Maybe(fulfillment)._.destroy
  end

end
