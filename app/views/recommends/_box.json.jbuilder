json.id box.id
json.number box.number
json.user_id box.user_id
json.user_name box.user.try(:name) || '小黄人'
json.user_image box.user.try(:image) || 'http://cdn.tips.draftbox.cn/users/1/FoFoVVyi9v0F5-nBpoF7JoTu0VhW.jpg'
json.user_badge box.user.try(:badge)
json.title box.title
json.state box.state
json.display_state box.display_state
json.period_type box.period_type
json.period box.period
json.price box.price
json.count_on_hand box.count_on_hand
json.tracking_inventory box.tracking_inventory
json.image box.image
json.qrcode_image box.qrcode_image
json.blur_images box.blur_images
json.sales box.sales
json.is_mine box.is_mine?(current_user)
json.can_access box.can_access?(current_user)
json.created_at box.created_at
json.updated_at box.updated_at