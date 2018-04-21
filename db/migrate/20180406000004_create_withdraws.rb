class CreateWithdraws < ActiveRecord::Migration[5.1]
  def change
    create_table :withdraws do |t|
      t.integer :user_id
      t.string :request_id
      t.decimal :amount, precision: 12, scale: 2
      t.text :comment
      t.timestamps
    end
  end
end
