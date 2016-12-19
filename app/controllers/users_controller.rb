class UsersController < ApplicationController

	##################
	##################
	##################
	##################
	##################
	##################
	# currently superceded by devise_token_auth's own routes






	# def create
	# 	@user = User.new(user_params)
	# 	if @user.save
	# 		render json: {message: "¡Registro realizado correctamente! Revisa tu email para activar tu cuenta!", result:"success"}, status: 201
	# 	else
	# 		render json: {errors: @user.errors, result: "failure"}, status: 422
	# 	end
	# end

	# def show
	# 	if @user = User.find(params[:email])
	# 		render json: @user # For this it might be useful to install & use active_model_serializers
	# 	else
	# 		render json: {errors: @user.errors}, status: 500
	# 	end
	# end

	# def update

	# end

	# def destroy

	# end


	# private

	# def user_params

	# 	params.require(:signup_data).permit(:name, :email, :password, :password_confirmation)
		
	# end

	
end
