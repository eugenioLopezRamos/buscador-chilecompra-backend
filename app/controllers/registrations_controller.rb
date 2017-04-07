# Overrides for devise token auth registrations controller
class RegistrationsController < DeviseTokenAuth::RegistrationsController
  # ALTERAR EL RESULTADO FINAL DE #UPDATE
  def render_update_error
    render json: json_message(errors: 'No se pudo actualizar. Ingresaste tu contraseña?'),
           status: 422
  end

  def account_update_params
    params.permit(:name, :nickname, :email, :password, :password_confirmation, :current_password, :image)
  end
end
