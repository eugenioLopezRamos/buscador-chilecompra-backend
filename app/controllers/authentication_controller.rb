class AuthenticationController < ApplicationController
#https://www.sitepoint.com/introduction-to-using-jwt-in-rails/
  def authenticate_user
    login_data = params[:login_data]
    user = User.find_for_database_authentication(email: login_data[:email])
    if user.valid_password?(login_data[:password])
      render json: payload(user)
    else
      render json: {errors: ['Usuario/Contraseña inválidos']}, status: :unauthorized
    end
  end

  private

  def payload(user)
    return nil unless user and user.id
    {
      auth_token: JsonWebToken.encode({user_email: user.email}),
      user: {name: user.name, email: user.email},
      result: "success"
    }
  end



end
