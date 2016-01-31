class ChangeDataTypeForProductPrice < ActiveRecord::Migration
  def up
    remove_column :products, :product_price
    add_column :products, :product_price, :float, default: 0
  end

  def down
    change_column :products, :product_price, :string
  end
end
