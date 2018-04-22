json.data do
  json.number @order.number
  json.payment_total @order.payment_total
  json.total @order.total
  json.prepay_id @order.prepay_id
  json.state @order.state
  json.sign @sign
  json.time_stamp @time_stamp
  json.app_id @app_id
  json.nonce_str @nonce_str
  json.sign_type @sign_type
  json.completed_at @order.completed_at
  json.created_at @order.created_at
  json.updated_at @order.updated_at
end