class RouteVisit < ActiveRecord::Base
	belongs_to :route_plan
	belongs_to :visit_window
	has_many :sales_orders, :dependent => :nullify
	has_many :item_levels, :dependent => :destroy, autosave: true
end