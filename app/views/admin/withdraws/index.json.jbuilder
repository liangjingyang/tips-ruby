json.meta do
  json.partial! 'shared/pagination', relation: @withdraws
end

json.data @withdraws do |withdraw|
  json.partial! 'show', withdraw: withdraw
end