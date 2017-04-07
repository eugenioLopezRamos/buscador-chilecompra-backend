# App controller
class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ApplicationHelper

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # devise_token_auth doesn't seem to use custom failure apps like devise does.
  def authenticate_user!
    return if current_user
    render json: json_message(errors: 'Acceso denegado. Por favor ingresa.'), status: 401
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
