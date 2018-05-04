json.meta do
  json.partial! 'shared/pagination', relation: @boxes
end

json.data @boxes do |box|
  json.partial! 'show', box: box
end