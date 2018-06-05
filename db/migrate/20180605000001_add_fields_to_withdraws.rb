class AddFieldsToWithdraws < ActiveRecord::Migration[5.1]
  def change
    add_column :withdraws, :real_name, :string
    add_column :withdraws, :id_card, :string
    add_column :withdraws, :bank_card, :string
  end
end