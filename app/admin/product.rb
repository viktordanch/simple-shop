ActiveAdmin.register Product do
  config.per_page = 100
  # filter :category_path,
  #        collection: -> { Category.all },
  #        label:      'Category'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :product_sku, :manufacturer_name,
              :product_name, :product_price, :published, :category_path,
              :product_desc
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end
  form do |f|
    f.inputs do
      f.input :product_name
      f.input :manufacturer_name
      f.input :product_price
      f.input :published
      f.input :product_sku
      f.input :product_desc
      f.input :product_s_desc
    end
    f.inputs do
      f.input :category, label: 'category', as: :select,
              collection: Category.all.sort.map{|c| ["#{c.category_path}", c.category_path]}
    end
    f.actions
  end
end
