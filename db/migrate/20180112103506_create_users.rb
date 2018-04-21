class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :unionid
      t.string :openid
      t.string :session_key
      t.string :app_id

      t.string :language
      t.string :country
      t.string :province
      t.string :city
      t.string :sex

      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""
      t.string :encrypted_captcha, :null => false, :default => ""

      t.string :image
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :users, :openid, unique: true
  end
end
