# ProductsController
class ProductsController < ApplicationController
  layout 'my_shop_b'

  respond_to :html, :json

  def product_by_page
    page = params[:page] || 1

    if params[:category]
      products = Product.where("category_path like ?", "%#{params[:category]}%").page(params[:page] || 1).per(4)
    else
      products = Product.page(params[:page] || 1).per(4)
    end
    # require 'pry'; binding.pry;
    render json: {
               products: products,
               page: page,
               total: products.num_pages
           }
  end

  def index
    @catalog = Category.catalog
    if params[:category]
      @products = Product.where("category_path like ?", "%#{params[:category]}%").page(params[:page] || 1).per(4)
    else
      @products = Product.page(params[:page] || 1).per(4)
    end

    # @products

    respond_to do |format|
      format.js {
        render json: {
          products: @products,
          category: params[:category],
          page: params[:page] || 1,
        }.to_json
      }
      format.html
    end
  end

  def show
    @product   = Product.find_by_id(params[:id])
  end

  def list
    books = [1, 2, 3, 4].map do |n|
      { title: "book #{n}",
        description: "Some description for book #{n}",
        image: "/iamge#{n}.png"
      }
    end

    respond_to do |format|
      format.js { render json: books.to_json }
      format.html
    end
  end
end
