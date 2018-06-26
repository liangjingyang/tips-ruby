class AddFakeSalesToBoxes< ActiveRecord::Migration[5.1]
  def change
    add_column :boxes, :fake_sales, :integer, default: 0
  end
end