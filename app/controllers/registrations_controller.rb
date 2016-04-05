# CartController
class RegistrationsController < Devise::RegistrationsController
  layout :check_api_params

  def after_inactive_sign_up_path_for(_resource)
    root_path
  end
end
