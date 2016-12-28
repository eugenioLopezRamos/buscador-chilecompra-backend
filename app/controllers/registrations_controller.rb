class RegistrationsController < DeviseTokenAuth::RegistrationsController
    def account_update_params
        params.permit(:name, :nickname, :email, :password, :password_confirmation, :current_password, :image)
    end
end

