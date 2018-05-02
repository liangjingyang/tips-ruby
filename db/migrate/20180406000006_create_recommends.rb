class CreateRecommends < ActiveRecord::Migration[5.1]
  def change
    create_table :recommends do |t|
      t.integer :user_id
      t.integer :box_id
      t.decimal :retail_price, precision: 12, scale: 2, default: 0, null: false
      t.text :description
      t.timestamps
    end
  end
end
