class AddImageToCategory < ActiveRecord::Migration
  def up
    add_attachment :category_images, :category_image
  end

  def down
    remove_attachment :category_images, :category_image
  end
end
