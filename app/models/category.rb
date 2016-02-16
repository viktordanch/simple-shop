class Category < ActiveRecord::Base
  has_one :category_image

  accepts_nested_attributes_for :category_image

  def to_s
    "#{category_name} || #{category_path}"
  end

  def to_json
    {
        category_name: category_name,
        category_path: category_path,
        image_thumb: category_image ? category_image.category_image.url(:thumb) : '/system/missing.png'
    }
  end

  def self.get_nested_categories_urls(hash)
    s_category = hash.to_s.split('/')
    
    s_catalog = catalog[s_category[0]] if s_category.count == 1
    s_catalog = catalog[s_category[0]][s_category[1]] if s_category.count == 2
    s_catalog = catalog[s_category[0]][s_category[1]][s_category[2]] if s_category.count == 3
    s_catalog = catalog[s_category[0]][s_category[1]][s_category[2]][s_category[3]] if s_category.count == 4
    s_catalog = catalog[s_category[0]][s_category[1]][s_category[2]][s_category[3]][s_category[4]] if s_category.count == 5
    s_catalog = catalog[s_category[0]][s_category[1]][s_category[2]][s_category[3]][s_category[4]][s_category[5]] if s_category.count == 6

    full_urls = (s_catalog || {}).keys.map do |k|
      hash.to_s[-1] == '/' ? (hash.to_s + k) : (hash.to_s + '/' + k)
    end

    full_urls
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: "^"})
      when ".xls" then Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)

    header = spreadsheet.row(1)
    rows_range = (2..spreadsheet.last_row)
    rows_range.each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      if where(row).blank?
        return { error_row: row } unless create(row)
      end
    end

    { loaded_rows_count: rows_range.count }
  end

  def self.catalog
    categories = {}
    pathes = select("DISTINCT category_path").map(&:category_path)

    pathes.each do |path|
      path_array = path.split('/')
      path_array.each_with_index do |sub_category, index|
        if index == 0
          categories[path_array[0]] = {} if !categories[path_array[0]]
        elsif index == 1
          categories[path_array[0]][path_array[1]] = {} if !categories[path_array[0]][path_array[1]]
        elsif index == 2
          categories[path_array[0]][path_array[1]][path_array[2]] = {} if !categories[path_array[0]][path_array[1]][path_array[2]]
        elsif index == 3
          categories[path_array[0]][path_array[1]][path_array[2]][path_array[3]] = {} if !categories[path_array[0]][path_array[1]][path_array[2]][path_array[3]]
        elsif index == 4
          if !categories[path_array[0]][path_array[1]][path_array[2]][path_array[3]][path_array[4]]
            categories[path_array[0]][path_array[1]][path_array[2]][path_array[3]][path_array[4]] = {}
          end
        elsif index == 5
          if !categories[path_array[0]][path_array[1]][path_array[2]][path_array[3]][path_array[4]][path_array[5]]
            categories[path_array[0]][path_array[1]][path_array[2]][path_array[3]][path_array[4]][path_array[5]] = {}
          end
        end
      end
    end

    categories
  end
end
