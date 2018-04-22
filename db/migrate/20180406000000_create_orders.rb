class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :number
      t.string :prepay_id
      t.string :transaction_id
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :box_id
      t.integer :following_id
      t.integer :quantity
      t.decimal :price, precision: 12, scale: 2
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :reason
      t.string :client_payment_result
      t.string :state, default: :pending, null: false
      t.decimal :total, precision: 12, scale: 2
      t.timestamps
    end
  end
end
