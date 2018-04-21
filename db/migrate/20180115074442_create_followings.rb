class CreateFollowings < ActiveRecord::Migration[5.1]
  def change
    create_table :followings do |t|
      t.integer :user_id
      t.integer :box_id
      t.string :seller_name
      t.string :seller_image
      t.datetime :started_at
      t.datetime :expired_at

      t.timestamps
    end
  end
end
