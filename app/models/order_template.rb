class OrderTemplate < ActiveRecord::Base

  belongs_to :location

  has_many :order_template_items
  has_many :order_template_days
end
