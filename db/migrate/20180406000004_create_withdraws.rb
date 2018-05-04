class CreateWithdraws < ActiveRecord::Migration[5.1]
  def change
    create_table :withdraws do |t|
      t.integer :user_id
      t.string :number
      t.decimal :amount, precision: 12, scale: 2, default: 0, null: false
      t.string :state, default: :applied, null: false
      t.string :reason
      t.text :comment
      t.datetime :applied_at
      t.datetime :approved_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.datetime :released_at
      t.datetime :canceled_at
      t.integer :approved_by
      t.integer :released_by
      t.timestamps
    end
  end
end
