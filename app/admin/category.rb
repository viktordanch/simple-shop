ActiveAdmin.register Category do
  config.per_page = 100

  permit_params :category_name, :category_name, :file_url, category_image_attributes: [ :category_image ]

  index do
    selectable_column
    column 'Name', :category_name
    column 'Path', :category_path
    column "Image" do |category|
      image_tag category.category_image ? category.category_image.category_image.url(:thumb) : 'No image'
    end
    actions
  end

  form html: { multipart: true } do |f|
    f.inputs do
      f.input :category_name
      f.input :category_path
    end

    f.inputs name: "Image", for: [:category_image, f.object.category_image || CategoryImage.new ] do |img_form|
      img_form.input :category_image, as: :file, hint: f.object.category_image.present? ? image_tag(f.object.category_image.category_image.url(:thumb)) : content_tag(:span, "no cover page yet")
      # img_form.actions
    end
    f.actions
  end
end
