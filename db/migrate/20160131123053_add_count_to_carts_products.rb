class AddCountToCartsProducts < ActiveRecord::Migration
  def change
    add_column :carts_products, :count, :integer
  end
end
