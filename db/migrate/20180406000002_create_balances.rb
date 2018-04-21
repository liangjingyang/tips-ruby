class CreateBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :balances do |t|
      t.integer :user_id
      t.integer :fee_rate # 千分位 5% 是 50
      t.decimal :amount, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total_sales, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total_profit, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total_withdraw, precision: 12, scale: 2, default: 0, null: false
      t.timestamps
    end
  end
end
