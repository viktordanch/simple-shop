# CartController
class CartController < ApplicationController
  include ActionView::Helpers::NumberHelper
  layout 'my_shop_b'

  def add_product
    product = Product.find_by_id(params[:product_id])
    count = params[:count].to_i || 1

    if product
      # require 'pry'; binding.pry
      carts_product = CartsProduct.where(cart_id: @cart.id, product_id: product.id).first

      if carts_product
        carts_product.update_attributes(count: count + carts_product.count)
      else
        CartsProduct.create(cart_id: @cart.id, product_id: product.id, count: count)
      end

      render json: { message: 'product added', count: @cart.carts_products.sum(:count) }.to_json
    else
      render json: { message: 'product not found' }.to_json, status: 404
    end

  end

  def update_product_count
    product_id = params[:product_id]
    count = params[:count]

    # require 'pry'; binding.pry
    cart_product = CartsProduct.where(cart_id: @cart.id, product_id: product_id).first

    cart_product.update_attributes(count: count) if cart_product

    @carts_products = @cart.carts_products.all

    total_price = @carts_products.map { |cart| cart.product_price.to_f * cart.count.to_f }.sum
    render json: {
               carts_products: @carts_products.map do |product|
                 { art_number: product.product_sku,
                   name: product.product_name,
                   count: product.count,
                   id: product.product_id,
                   price: number_to_currency(product.product_price.to_f * product.count.to_f,
                                             unit: "грн",
                                             separator: ",",
                                             delimiter: "",
                                             format: "%n %u")
                 }
               end,
               total: number_to_currency(total_price,
                                         unit: "грн",
                                         separator: ",",
                                         delimiter: "",
                                         format: "%n %u")
           }.to_json
  end

  def index
    @carts_products = @cart.carts_products.all
    respond_to do |format|
      format.js {
        total_price = @carts_products.map { |cart| cart.product_price.to_f * cart.count.to_f }.sum
        render json: {
                   carts_products: @carts_products.map do |product|
                     { art_number: product.product_sku,
                       name: product.product_name,
                       count: product.count,
                       price: number_to_currency(product.product_price.to_f * product.count.to_f,
                                                 unit: "грн",
                                                 separator: ",",
                                                 delimiter: "",
                                                 format: "%n %u")
                     }
                   end,
                   total: number_to_currency(total_price,
                                             unit: "грн",
                                             separator: ",",
                                             delimiter: "",
                                             format: "%n %u")
               }.to_json }
      format.html
    end
  end
end
