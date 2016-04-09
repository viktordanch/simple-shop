ActiveAdmin.register ProductImage do
  permit_params :image, :product_id, :number
  config.sort_order = 'product_id number'

  index do
    selectable_column
    column :id
    column :updated_at
    column :number
    column "Preview" do |product_image|
      image_tag(product_image.image.url(:thumb))
    end
    column "Product" do |product_image|
      product = product_image.product
      "#{product ? product.product_name : ''} (#{product ? product.product_sku : ''})"
    end
    actions
  end

  csv do
    column :number
    column(:product_sku){ |product_image| product_image.product ? product_image.product.product_sku : '' }
    column :image_file_name
    column :image_content_type
    column :image_file_size
    column :image_updated_at
  end

  form do |f|
    f.inputs "Project Details" do
    f.input :product_id, label: 'Product', as: :select, input_html: { class: "chosen-input" },
            collection: Product.all.map{|p| ["#{p.product_name}, #{p.product_sku}", p.id]}
    f.input :image, as: :file
    f.input :number
      # Will preview the image when the object is edited
    end
    f.actions
  end

  show do |ad|
    attributes_table do
      row :number
      row :product_id do
        Product.find_by_id(ad.product_id.to_i) || ''
      end
      row :image do
        image_tag(ad.image.url(:thumb))
      end
      # Will display the image on show object page
    end
  end

  # form do |f|
  #   f.inputs 'Edit' do
  #     # f.input :products, as: :select, html: { multipart: true }, collection: Product.all
  #     f.input :products, :input_html => { :class => "chosen-input" } # other model with has_many relation ship
  #     f.input :statuses, as: :check_boxes, collection: Status.all
  #     f.input :user, :as => :select
  #   end
  #   f.actions
  # end
end
