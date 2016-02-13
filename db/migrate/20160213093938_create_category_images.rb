class CreateCategoryImages < ActiveRecord::Migration
  def change
    create_table :category_images do |t|

      t.timestamps null: false
    end
  end
end
