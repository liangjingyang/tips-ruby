json.data do
  json.number @box.number
  json.title @box.title
  json.state @box.state
  json.period_type @box.period_type
  json.period @box.period
  json.price @box.price
  json.count_on_hand @box.count_on_hand
  json.tracking_inventory @box.tracking_inventory
  json.can_supply @box.can_supply?
  json.image @box.image
  json.sales @box.sales
  json.created_at @box.created_at
  json.updated_at @box.updated_at
  json.is_mine @box.is_mine(current_user)
  json.following @following.present?
  json.can_access @following.try(:can_access?)
end