class CreateBoxes < ActiveRecord::Migration[5.1]
  def change
    create_table :boxes do |t|
      t.integer :user_id
      t.string :user_name
      t.string :user_image
      t.string :image
      t.string :title
      t.string :state, default: :created, null: false
      t.string :number
      t.string :period_type
      t.integer :period #days
      t.decimal :price, precision: 12, scale: 2, default: 0, null: false
      t.integer :count_on_hand, default: 0, null: false
      t.boolean :tracking_inventory, default: false, null: false
      t.integer :sales, default: 0

      t.timestamps
    end
  end
end
