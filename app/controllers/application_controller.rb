# ApplicationController
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :cart
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
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
      message = "#{I18n.t('Please')}, #{I18n.t('before')} <a href='#{new_user_session_path}'" \
                " title=#{I18n.t('login')}>#{I18n.t('login')}</a> #{I18n.t('to site')}"
      redirect_to root_path,
                  notice: message
    end
  end

  # def configure_permitted_parameters
  # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:avatar, :username, :email, :password, :password_confirmation, :remember_me) }
  # devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:avatar, :username, :login, :email, :password, :remember_me) }
  # devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:avatar, :username, :email, :password, :password_confirmation, :current_password) }
  # end
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:last_name, :first_name, :address, :telephone, :email, :password, :password_confirmation)
    end
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:last_name, :first_name, :address, :telephone])
  end
end
