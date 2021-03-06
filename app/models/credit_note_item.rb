class CreditNoteItem < ActiveRecord::Base
  belongs_to :credit_note, touch: true
  belongs_to :item

  def has_credit?
    total > 0.0
  end

  def total
    quantity * unit_price
  end
end
