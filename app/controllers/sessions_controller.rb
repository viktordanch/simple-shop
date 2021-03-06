# CartController
class SessionsController < Devise::SessionsController
  layout :check_api_params

  protected

  # Login Path (if already logged in)
  def after_sign_in_path_for(_resource)
    root_path
  end

  # Logout Path
  def after_sign_out_path_for(_resource)
    root_path
  end
end
