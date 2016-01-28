class RouteVisitResource < JSONAPI::Resource
  attributes  :notes,
              :completed_at,
              :client_fingerprint,
              :arrive_at,
              :depart_at,
              :position,
              :fullfilled

  has_one :route_plan
  has_one :visit_window

  has_many :sales_orders
  has_many :custom_orders
  has_many :purchase_orders
  has_many :item_levels
end