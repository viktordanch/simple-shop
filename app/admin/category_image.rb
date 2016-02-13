ActiveAdmin.register CategoryImage do
  permit_params :category_image, :category_id

  index do
    selectable_column
    column 'Category' do |category_image|
      category_image.category ? category_image.category_name : 'No category'
    end
    column 'Category path' do |category_image|
      category_image.category ? category_image.category_path : 'No category'
    end
    column "Image" do |category_image|
      image_tag category_image.category_image.url(:thumb), class: 'my_image_size'
    end
    actions
  end

  form do |f|
    f.inputs "" do
      f.input :category_id, label: 'Category', as: :select, input_html: { class: "chosen-input" },
             collection: Category.all.map{|c| ["#{c.category_name}, #{c.category_path}", c.id]}
      f.input :category_image, as: :file, :hint => f.category_image.category_image.present? \
                             ? image_tag(f.category_image.category_image.url(:thumb))
                             : content_tag(:span, "no cover page yet")
    end
    f.actions
  end


end
