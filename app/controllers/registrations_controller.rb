# CartController
class RegistrationsController < Devise::RegistrationsController
  layout :check_api_params

  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      flash.now[:alert] = "#{I18n.t('There was an error with the recaptcha code below')}. #{I18n.t('Please re-enter the code')}"
      render :new
    end
  end

  def after_inactive_sign_up_path_for(_resource)
    root_path
  end
end
