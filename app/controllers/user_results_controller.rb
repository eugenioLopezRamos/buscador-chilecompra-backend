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
      #TODO: Fix in model too.
      rescue ArgumentError => message
        puts "MESSAGE #{message}"
        render json: json_message_to_frontend(errors: message)
      rescue ActiveRecord::RecordNotUnique
        render json: json_message_to_frontend(errors: "Error, ya está suscrito a este resultado y/o nombre ya existe")
    end

    def update
      # TODO: Just use the result_id? old_name is not really needed - Could go either way
      @name = valid_update_result_subscription_params[:name]
      @old_name = valid_update_result_subscription_params[:old_name]

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

      if current_user.destroy_result_subscription @result
        @message = json_message_to_frontend(info: "Suscripción cancelada exitosamente")
        @message[:subscriptions] = current_user.subscriptions
        return render json: @message
      end

      render json: json_message_to_frontend(errors: "No se pudo cancelar la suscripción")

      rescue ActiveRecord::ActiveRecordError
        render json: json_message_to_frontend(errors: "Error al cancelar la suscripción")
    end

    def show_history
      @id = valid_result_history_params
      @result = Result.find(@id)
      render json: @result.history
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

    def valid_result_history_params
      # "asdas".to_i.to_s = ("0" != "asdas")  => raise
      # "1asdas".to_i.to_s = ("1" != "1asdas") => raise
      # "asdas1".to_i.to_s = ("0" != "asdas1") => raise
      # "1asdas1".to_i.to_s = ("1" != "1asdas1") => raise
      if params[:id].to_i.to_s != params[:id]
        raise ArgumentError.new(json_message_to_frontend(errors: "Id de resultado debe ser un número entero"))
      end
      params.require(:id)

      rescue ArgumentError => e
        render json: e
    end


    # def valid_ids?
    #   new_arr = params["results"].map {|id| id.to_i}
    #   if new_arr != params["results"]
    #     render json: {"message": {"errors": ["Id(s) inválido(s)"] } }
    #   else
    #       return true

    #   end
    #   rescue NoMethodError #happens when |id| is null, for example
    #     render json: {"message": {"errors": ["Id(s) inválido(s)"] } }            
    # end

end
