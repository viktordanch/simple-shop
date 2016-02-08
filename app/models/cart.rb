# Cart model
class Cart < ActiveRecord::Base
  has_many :carts_products
  has_many :products, through: :carts_products

  def product_count
    carts_products.sum(:count)
  end
end
