class OrderTemplate < ActiveRecord::Base

  belongs_to :location

  has_many :order_template_items, :dependent => :destroy, autosave: true
  has_many :order_template_days, :dependent => :destroy, autosave: true
end
