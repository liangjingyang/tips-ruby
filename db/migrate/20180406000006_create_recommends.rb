class CreateRecommends < ActiveRecord::Migration[5.1]
  def change
    create_table :recommends do |t|
      t.integer :box_id
      t.integer :weight, default: 0, null: false
      t.string :comment
      t.timestamps
    end
  end
end
