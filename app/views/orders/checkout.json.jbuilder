json.data do
  json.number @order.number
  json.payment_total @order.payment_total
  json.total @order.total
  json.payment_order_id @order.payment_order_id
  json.state @order.state
  json.completed_at @order.completed_at
  json.created_at @order.created_at
  json.updated_at @order.updated_at
end