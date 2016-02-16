# CartController
class CartController < ApplicationController
  include ActionView::Helpers::NumberHelper

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

      render json: { message: 'product added', count: @cart.product_count }.to_json
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
    # require 'pry'; binding.pry
    @carts_products = @cart.carts_products.all.sort_by{ |e| e.product_name }

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
                                         format: "%n %u"),
               total_count: @cart.product_count
           }.to_json
  end

  def index
    @carts_products = @cart.carts_products.all
    @carts_products = @cart.carts_products.all.sort_by{ |e| e.product_name }
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

  def destroy
    cart_product = CartsProduct.where(product_id: params[:product_id], cart_id: @cart.id).first

    if cart_product && cart_product.destroy
      respond_to do |format|
        format.js { render json: { message: 'removed', count: @cart.product_count } }
        format.html {
          redirect_to :back
        }
      end
    else
      respond_to do |format|
        format.js { render json: { message: 'error' }, status: 401 }
        format.html {
          redirect_to :back
        }
      end
    end
  end
end
