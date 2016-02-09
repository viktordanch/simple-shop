ActiveAdmin.register Product do
  config.per_page = 100

  permit_params :product_sku, :manufacturer_name,
                :product_name, :product_price, :published, :category_path,
                :product_desc,
                class_dates_attributes: [ :image ]

  index do
    selectable_column
    column 'sku', :product_sku
    column 'm_name', :manufacturer_name
    column 'name', :product_name
    column 'price', :product_price
    column :published
    column :category_path
    column :product_desc
    actions
  end

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
      f.input :category, label: 'category', as: :select, input_html: { class: "chosen-input" },
              collection: Category.all.sort.map{|c| ["#{c.category_path}", c.category_path]}
    end
    f.inputs "Product images" do
      f.has_many :product_images, new_record: true do |p|
        p.input :image, as: :file
                # hint: p.object.image.nil? ? p.template.content_tag(:span, "No Image Yet") : p.template.image_tag(p.object.image.url(:thumb))
        # p.actions
      end
    end

    f.actions
  end
end
