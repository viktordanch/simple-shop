class AddNumberToProductImages < ActiveRecord::Migration
  def change
    add_column :product_images, :number, :integer
  end
end
