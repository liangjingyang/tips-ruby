# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

random = Random.new(1)
now = Time.now
user = User.create!(openid: 1, name: "test1", app_id: "ed1", image: "http://cdn.tips.draftbox.cn/users/1/FoFoVVyi9v0F5-nBpoF7JoTu0VhW.jpg")
User.create!(openid: 2, name: "test2", app_id: "ed2", image: "http://cdn.tips.draftbox.cn/users/1/FoFoVVyi9v0F5-nBpoF7JoTu0VhW.jpg")
box = user.boxes.create!(title: 'box_title', price: 0.1, count_on_hand: 10)
box.number = "BX0000000000"
box.save
post = box.posts.create!(content: "post content", images: ["http://cdn.tips.draftbox.cn/users/1/FoFoVVyi9v0F5-nBpoF7JoTu0VhW.jpg"])