class AddCategoryIdToCategoryImage < ActiveRecord::Migration
  def change
    add_reference :category_images, :category, index: true, foreign_key: true
  end
end
