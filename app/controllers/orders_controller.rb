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

    UserMailer.create_order(order.id).deliver_now
    UserMailer.create_order_admin(order.id).deliver_now
    
    flash[:notice] = I18n.t('Order successfully created')
    redirect_to action: :index
  end

  def index
    @orders = current_user.orders
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end
end
