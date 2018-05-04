json.meta do
  json.partial! 'shared/pagination', relation: @recommends
end

json.data @recommends do |recommend|
  json.partial! 'box', box: recommend.box
end