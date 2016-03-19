ActiveAdmin.register ProductImage do
  permit_params :image, :product_id

  form do |f|
    f.inputs "Project Details" do
    f.input :product_id, label: 'Product', as: :select, input_html: { class: "chosen-input" },
            collection: Product.all.map{|p| ["#{p.product_name}, #{p.product_sku}", p.id]}
    f.input :image, as: :file
      # Will preview the image when the object is edited
    end
    f.actions
  end

  show do |ad|
    attributes_table do
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
