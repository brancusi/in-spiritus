class RoutePlanBlueprintResource < JSONAPI::Resource
  attributes :name
  
  has_many :route_plan_blueprint_slots
end
