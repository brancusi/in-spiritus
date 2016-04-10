class Company < ActiveRecord::Base
  include AASM

  # State machine
  enum xero_state: [ :pending, :synced ]
  aasm :xero_syncable, :column => :xero_state, :skip_validation_on_save => true do
    state :pending, :initial => true
    state :synced

    event :mark_pending do
      transitions :from => :pending, :to => :pending
      transitions :from => :synced, :to => :pending
    end

    event :mark_synced do
      transitions :from => :pending, :to => :synced
      transitions :from => :synced, :to => :synced
    end
  end

  validates :name, :code, uniqueness: { case_sensitive: false }

  has_many :locations, :dependent => :destroy, autosave: true

  belongs_to :price_tier

  has_many :item_prices, through: :price_tier

	def price_for_item (item)
		match = item_prices
			.where(item:item)
			.first

		match.present? ? match.price : 0.0
	end

end
