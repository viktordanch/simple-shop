class OrdersProduct < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  delegate :product_name, to: :product, prefix: false
  delegate :product_price, to: :product, prefix: false
  delegate :product_sku, to: :product, prefix: false
end
