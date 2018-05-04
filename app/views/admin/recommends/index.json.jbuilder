json.meta do
  json.partial! 'shared/pagination', relation: @recommends
end

json.data @recommends do |recommend|
  json.partial! 'admin/boxes/show', box: recommend.box
end