

    class RegistrationsController < DeviseTokenAuth::RegistrationsController
        def account_update_params
           # binding.pry
            puts "PARAMS ARE #{params.to_json}"
            params.permit(:name, :nickname, :email, :password, :password_confirmation, :current_password, :image)
        end
    end

