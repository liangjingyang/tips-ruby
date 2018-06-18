class AddPhoneToWithdraws < ActiveRecord::Migration[5.1]
  def change
    add_column :withdraws, :phone, :string
  end
end