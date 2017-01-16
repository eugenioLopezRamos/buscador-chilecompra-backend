class UserResultsController < ApplicationController
    include UserResultsHelper

    before_action :authenticate_user!
    #before_action :valid_ids?, only: [:create, :update, :create_stored_result]

    def show
      render json: current_user.subscriptions
    end

    def create
      @result_id = valid_create_result_subscription_params[:result_id]
      @name = valid_create_result_subscription_params[:name]
      current_user.subscribe_to_result(@result_id, @name)
      render json: json_message_to_frontend(info: "Suscripción guardada exitosamente")

      rescue ActiveRecord::RecordNotUnique
        render json: json_message_to_frontend(error: "Error, ya está suscrito a este resultado y/o nombre ya existe")
      #render json: create_subscription(valid_create_result_subscription_params)
    end

    def update
      @name = valid_update_result_subscription_params[:name]
      @old_name = valid_update_result_subscription_params[:old_name]
      @message = ""

      if current_user.update_result_subscription(@old_name, @name)
        @message = json_message_to_frontend(info: "Actualizado exitosamente")
        @message[:subscriptions] = current_user.subscriptions
        return render json: @message
      end

        render json: json_message_to_frontend(error: "Lo sentimos, hubo un error. Por favor inténtalo nuevamente")

      rescue ActiveRecord::RecordNotUnique
        render json: json_message_to_frontend(error: "Error, este nombre ya existe")
    end

    def destroy
      @result = valid_destroy_result_subscription_params[:name]
      @message = ""

      if current_user.destroy_result_subscription @result
        @message = json_message_to_frontend(info: "Suscripción cancelada exitosamente")
        @message[:subscriptions] = current_user.subscriptions
        return render json: @message
      end

      render json: json_message_to_frontend(errors: "No se pudo cancelar la suscripción")

      rescue ActiveRecord::ActiveRecordError
        render json: json_message_to_frontend(errors: "Error al cancelar la suscripción")
    end

    private

    def valid_create_result_subscription_params
      params.require(:create_subscription).permit(:name, :result_id)
    end

    def valid_update_result_subscription_params
      params.require(:update_subscription).permit(:old_name, :name)
    end

    def valid_destroy_result_subscription_params
      params.require(:destroy_subscription).permit(:name)
    end

    def valid_ids?
      new_arr = params["results"].map {|id| id.to_i}
      if new_arr != params["results"]
        render json: {"message": {"errors": ["Id(s) inválido(s)"] } }
      else
          return true

      end
      rescue NoMethodError #happens when |id| is null, for example
        render json: {"message": {"errors": ["Id(s) inválido(s)"] } }            
    end

end
