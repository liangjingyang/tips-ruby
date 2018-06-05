class AddFieldsToWithdraws < ActiveRecord::Migration[5.1]
  def change
    add_column :withdraws, :real_name, :string
    add_column :withdraws, :id_card, :string
    add_column :withdraws, :bank_card, :string
    add_column :withdraws, :rejected_at, :datetime
    add_column :withdraws, :rejected_by, :integer
    remove_column :withdraws, :canceled_at
    remove_column :withdraws, :released_at
    remove_column :withdraws, :released_by
  end
end