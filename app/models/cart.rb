# Cart model
class Cart < ActiveRecord::Base
  has_many :carts_products
  has_many :products, through: :carts_products
end
