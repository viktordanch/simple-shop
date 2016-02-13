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
end
