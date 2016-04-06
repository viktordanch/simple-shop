# CartController
class ConfirmationsController < Devise::ConfirmationsController

  protected

  def after_confirmation_path_for(resource_name, resource)
    sign_in resource unless signed_in?
    root_path
  end
end
