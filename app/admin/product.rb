ActiveAdmin.register Product do
  config.per_page = 100

  filter :category, label: "Category", as: :select, collection: Category.all
  filter :product_name
  filter :product_sku
  filter :product_s_desc
  filter :product_desc
  filter :manufacturer_name
  filter :product_price
  filter :category_path

  permit_params :product_sku, :manufacturer_name,
                :product_name, :product_price, :published, :category_path,
                :product_desc, _destroy: true,
                product_images_attributes: [:id, :_destroy, :image]

  index do
    selectable_column
    column 'sku', :product_sku
    column 'm_name', :manufacturer_name
    column 'name', :product_name
    column 'price', :product_price
    column :published
    column :category_path
    column :product_desc
    column "images count" do |product|
      count = product.product_images.count
      count > 0 ? count : 'No Images'
    end
    actions
  end

  show do
    attributes_table do
      row :product_sku
      row :manufacturer_name
      row :product_name
      row :product_price
      row :published
      row :category_path
      row :product_desc
    end
    # column 'sku', :product_sku
    # column 'm_name', :manufacturer_name
    # column 'name', :product_name
    # column 'price', :product_price
    # column :published
    # column :category_path
    # column :product_desc
    panel "Images" do
      table_for product.product_images.order(:number) do
        column "Images" do |product_image|
          image_tag product_image.image ? product_image.image.url(:thumb) : 'No image'
        end
       column "nuber" do |product_image|
         product_image.number
       end
       column "link" do |product_image|
         a 'show', href: admin_product_image_path(product_image)
         a 'edit', href: edit_admin_product_image_path(product_image)
         # image_tag product_image.image ? product_image.image.url(:thumb) : 'No image'
        end
      end
    end
    active_admin_comments
  end

  form html: { multipart: true } do |f|
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
    f.has_many :product_images, heading: 'Themes', allow_destroy: true, new_record: false do |p|
      p.input :image, as: :file, hint: p.object ? p.template.image_tag(p.object) : content_tag(:span, p.object)
    end

    f.actions
  end
end
