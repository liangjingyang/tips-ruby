json.meta do
  json.partial! 'shared/pagination', relation: @orders
end

json.data @orders do |order|
  json.partial! 'show', order: order
end