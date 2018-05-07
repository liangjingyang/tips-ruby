json.id box.id
json.number box.number
json.user_id box.user_id
json.user_name box.user.try(:name) || '[小黄人]'
json.user_image box.user.try(:image) || 'http://cdn.tips.draftbox.cn/users/1/FoFoVVyi9v0F5-nBpoF7JoTu0VhW.jpg'
json.title box.title
json.state box.state
json.period_type box.period_type
json.period box.period
json.price box.price
json.count_on_hand box.count_on_hand
json.tracking_inventory box.tracking_inventory
json.image box.image
json.sales box.sales
json.created_at box.created_at
json.updated_at box.updated_at
