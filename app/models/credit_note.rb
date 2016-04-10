class CreditNote < ActiveRecord::Base
  include AASM

  # State machine settings
  enum xero_state: [ :pending, :submitted, :synced, :voided ]
  enum notifications_state: [ :unprocessed, :processed ]

  aasm :credit_note, :column => :xero_state, :skip_validation_on_save => true, :no_direct_assignment => true do
    state :pending, :initial => true
    state :submitted
    state :synced
    state :voided

    event :mark_submitted do
      transitions :from => :pending, :to => :submitted
    end

    event :mark_synced do
      transitions :from => :submitted, :to => :synced
      transitions :from => :synced, :to => :synced
    end

    event :void do
      transitions :from => [:pending, :submitted, :synced], :to => :voided
    end
  end

  aasm :notifications, :column => :notifications_state, :skip_validation_on_save => true, :no_direct_assignment => true do
    state :unprocessed, :initial => true
    state :processed

    event :process do
      transitions :from => :unprocessed, :to => :processed
    end
  end

  after_create :generate_credit_note_number

  belongs_to :location

  has_one :fulfillment, dependent: :nullify, autosave: true
  has_many :credit_note_items, -> { joins(:item).order('position') }, :dependent => :destroy, autosave: true

  private
    def generate_credit_note_number
      if self.credit_note_number.nil?
        self.credit_note_number = "CR-#{date.strftime('%y%m%d')}-#{id}"
        save
      end
    end
end