class CategoryImage < ActiveRecord::Base
  belongs_to :category

  delegate :category_name, to: :category
  delegate :category_path, to: :category

  do_not_validate_attachment_file_type :category_image

  has_attached_file :category_image, default_url: '/system/missing.png',
                    url: "/system/:attachment/:style_:basename.:extension",
                    path: ":rails_root/public/system/:attachment/:style_:basename.:extension",
                    styles: {
                        thumb: '100x100>',
                        square: '200x200#'
                    }
end
