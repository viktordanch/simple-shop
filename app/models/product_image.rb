class ProductImage < ActiveRecord::Base
  belongs_to :product

  def to_s
    "#{image}"
  end

  # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :image, default_url: '/system/missing.png',
                            url: "/system/:attachment/:style_:basename.:extension",
                            path: ":rails_root/public/system/:attachment/:style_:basename.:extension",
                            styles: {
                                thumb: '100x100>',
                                square: '200x200#'
                            }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def self.open_spreadsheet(file)

    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: "^", quote_char: '"' })
      when ".xls" then Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.import_table(file)
    spreadsheet = open_spreadsheet(file)

    header = spreadsheet.row(1).map do |h|
      h.downcase!
      h.gsub!(' ', '_') if h.include?(' ')
      h = 'product_id' if h == 'product'
      h
    end

    rows_range = (2..spreadsheet.last_row)
    rows_range.each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product_image = where(number: row["number"], product_id: row["product_id"]).first
      if !product_image
        product_image = create(row)

        unless product_image
          message = { error_row: row }
        end
      else
        product_image.update_attributes(row)
      end
    end
  end
end
