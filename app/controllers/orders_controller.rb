# CartController
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    order = current_user.orders.create
    @cart.carts_products.each do |cart_product|
      # require 'pry'; binding.pry
      OrdersProduct.create(product_id: cart_product.product_id,
                           order_id: order.id,
                           count: cart_product.count.to_i)
      cart_product.destroy
    end

    redirect_to action: :index, notice: 'Order successfully created'
  end

  def index
    @orders = current_user.orders
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end
end
