class CreateActionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :action_logs do |t|
      t.datetime :created_at
      t.integer :user_id, foreign_key: true
      t.string :action_name
      t.string :controller_name
      t.jsonb :params

      t.timestamps
    end
  end
end
