# ProductsController
class ProductsController < ApplicationController
  layout 'my_shop_b'

  respond_to :html, :json

  def search
    param = params[:q]
    products = Product.where('product_sku like (?) OR product_name like (?) OR manufacturer_name like (?)',
                  "%#{param}%", "%#{param}%", "%#{param}%").first(5)
    response = products.map { |product| { id: product.id, name: "#{product.product_sku}; #{product.product_name}"}}
    render json: response.to_json
  end

  def product_by_page
    page = params[:page] || 1

    if params[:category]
      products = Product.where(category_path: params[:category]).page(params[:page] || 1).per(4)
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

    if !params[:category].blank?
      full_urls = Category.get_nested_categories_urls(params[:category])

      @categories = Category.where(category_path: full_urls)

      category = Category.where(category_path: params[:category]).first
      if category
        @products = Product.where("category_path = ?", "#{params[:category]}").page(params[:page] || 1).per(4)
        # @products.each { |category|  }
      end
    else
      @categories = Category.where(category_path: @catalog.keys)
      # @categories = Category.where("category_path = ?", "#{'Кухня/Все серии/ФАКТУМ,РАТИОНЕЛЬ серия Дверцы'}")
      @products = []
    end

    # @products

    respond_to do |format|
      format.js {
        render json: {
          products: @products.to_a,
          categories: @categories.map { |c| c.to_json },
          category: params[:category],
          page: params[:page] || 1,
        }.to_json
      }
      format.html
    end
  end

  def show
    @product = Product.find_by_id(params[:id])
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
