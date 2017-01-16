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
        render json: json_message_to_frontend(error: "Error, ya esta suscrito a este resultado y/o nombre ya existe")


      #render json: create_subscription(valid_create_result_subscription_params)
    end

    def update
      render json: update_subscription(valid_update_result_subscription_params)
    end

    def destroy
      render json: cancel_subscription(valid_destroy_result_subscription_params)
    end

    private

    def valid_create_result_subscription_params
      params.require(:create_subscription).permit(:name, :result_id)
    end

    def valid_update_result_subscription_params
      params.require({:update_subscription => [:name, :result_id]})
    end

    def valid_destroy_result_subscription_params
      params.require({:cancel_subscription => [:result_id]})
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
