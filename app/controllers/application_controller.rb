# ApplicationController
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :cart
  before_action :set_locale
  # def set_locale
  #   # I18n.locale = params[:locale]
  #   I18n.locale = params[:locale]
  # end
  #
  # def self.default_url_options(options={})
  #   options.merge({ :locale => I18n.locale })
  # end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  protected

  def check_api_params
    params[:api] ? false : 'application'
  end

  def cart
    @cart = ::Cart.find_by_id(session[:cart_id])

    unless @cart
      @cart = ::Cart.create
      session[:cart_id] = @cart.id
    end
  end

  def authenticate_user!
    if user_signed_in?
      super
    else
      message = "Please <a href='#{new_user_session_path}'" \
                " title='Sign in'>sign in</a> before"
      redirect_to root_path,
                  notice: message
    end
  end
end
