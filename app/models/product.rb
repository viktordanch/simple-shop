class Product < ActiveRecord::Base
  belongs_to :category, foreign_key: :category_path, primary_key: 'category_path'
  has_many :product_images
  has_many :carts_products
  has_many :orders_products
  has_many :products, through: :orders_products
  has_many :carts, through: :carts_products

  accepts_nested_attributes_for :product_images, allow_destroy: true

  def to_s
    "#{product_name} || #{product_sku}"
  end

  def main_image_url(style)
    product_images.order(:number).first.image.url(style)
  end

  def to_json_with_image
    product = self.to_json
    product = JSON.parse(product)
    product["image_url"] = self.main_image_url(:thumb)
    product
  end

  def self.open_spreadsheet(file)

    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: "^", quote_char: '"' })
      when ".xls" then Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.import_description(file)
    spreadsheet = open_spreadsheet(file)

    header = spreadsheet.row(1)
    rows_range = (2..spreadsheet.last_row)
    rows_range.each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      product = where(product_sku: row['product_sku']).first
      if product
        product.product_desc = row['product_desc']
        product.product_s_desc = row['product_desc']
        return { error_row: row } unless product.save
      end
    end

    { loaded_rows_count: rows_range.count }
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)

    header = spreadsheet.row(1)
    rows_range = (2..spreadsheet.last_row)
    rows_range.each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = where(row).first
      if !product
        product = create(row)

        unless product
          message = { error_row: row }
        end

      else
        product.update_attributes(row)
      end

      path_arr = product.category_path.to_s.split('/')
      path_arr.each do |category_name|
        index = path_arr.find_index(category_name)
        c_path = path_arr.take(index + 1).join('/')
        category= Category.find_by_category_path(c_path)
        Category.create({ category_name: category_name, category_path: c_path }) if !category
        # p category
      end
    end

    { loaded_rows_count: rows_range.count }
  end

  def self.import_products_images(temp_file)

    load_status = LoadStatus.create(start: true)
    count = 0
    names = []
    no_products = []
    begin

      Zip::File.open(temp_file.path).each do |entry|
        # entry is a Zip::Entry
        filename = File.join('public/extracted/' + entry.name)
        logger.debug "will extract file to #{filename} to"
        entry.extract(filename) unless File.exist?(filename)
        p = File.new(filename)
        image_name = filename.split('/').last
        count += 1
        names << filename.split('/').last

        product = self.find_by_product_sku(image_name.split('.').first.split('_').first)

        begin
          if product
            number = image_name.split('.').first.split('_').last
            product_image = product.product_images.where(number: number).first

            if product_image
              product_image.update_attributes(image: p)
            else
              product_image = ProductImage.create!(image: p, number: number)
              product.product_images << product_image
              product.save
            end
          else
            no_products << image_name
          end
        rescue => ex
          notification = notification || { alert: (notification || '') + "error to load #{ex.message}" }
          notification[:alert] += " error to load #{ex.message}"
          load_status.update_attributes(error: ex.message)
        end

        p.close
        File.delete(filename) if File.exist?(filename) && File.file?(filename)
      end

    rescue => ex
      load_status.update_attributes(error: ex.message)
    ensure

      temp_file.unlink if File.exists?( temp_file.path )
      # temp_file.close if File.exists?( temp_file.path )

      load_status.update_attributes(finish: true, error: "loaded success: #{count.to_s}, no_products: #{ no_products.join(',')}" )
    end
  end
end
