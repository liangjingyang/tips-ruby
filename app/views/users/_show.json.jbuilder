json.id user.id
json.name user.name
json.image user.image
json.box do
  json.partial! 'boxes/show', box: user.box, user: user
end
json.movement_updated_at user.movement_updated_at
json.movement_image user.movement_image