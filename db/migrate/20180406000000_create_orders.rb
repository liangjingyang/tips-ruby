class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :number
      t.string :prepay_id
      t.string :transaction_id
      t.integer :buyer_id
      t.integer :seller_id
      t.string :buyer_name
      t.string :seller_name
      t.string :buyer_image
      t.string :seller_image
      t.integer :box_id
      t.string :box_title
      t.integer :following_id
      t.integer :quantity
      t.decimal :price, precision: 12, scale: 2, default: 0, null: false
      t.integer :fee_rate # 千分位 5% 是 50
      t.decimal :fee, precision: 12, scale: 2, default: 0, null: false
      t.decimal :profit, precision: 12, scale: 2, default: 0, null: false
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :reason
      t.string :client_payment_result
      t.string :state, default: :pending, null: false
      t.decimal :total, precision: 12, scale: 2, default: 0, null: false
      t.timestamps
    end
  end
end
