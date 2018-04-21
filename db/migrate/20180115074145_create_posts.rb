class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.integer :box_id
      t.text :content
      t.jsonb :images
      t.jsonb :voices
      t.jsonb :videos

      t.timestamps
    end
  end
end
