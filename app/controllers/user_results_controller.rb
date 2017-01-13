class UserResultsController < ApplicationController
    include UserResultsHelper

    before_action :authenticate_user!
    before_action :valid_ids?, only: [:create, :update, :create_stored_result]
    # before_action :valid_show_results_values_params, only: [:show_results_values]
    # before_action :valid_create_result_subscription_params, only: :create_subscription
    # before_action :user_result_params, only: :create_stored_result


    def show_stored_results_values # grabs a result_name (say, "myownresult"), fetches all current_user's results with name "myownresult"
                            # and returns the values so they can be shown in the frontend
        render json: return_user_result_values(valid_show_results_values_params)
    end

    def create_stored_result
      @stored_result_name = user_result_params[:name]
      @stored_result_ids = user_result_params[:results]

      @message = current_user.create_stored_results @stored_result_ids, @stored_result_name

      render json: json_message_to_frontend(info: @message[:info], errors: @message[:errors])
    end

    def update_stored_result
      render json: update_stored_result(valid_update_result_subscription_params)
    end

    def delete_stored_result
      render json: delete_stored_result(valid_delete_stored_result_params)
    end










    def show_subscriptions
      render json: current_user.subscriptions
    end

    def create_subscription 
      render json: create_subscription(valid_create_result_subscription_params)
    end

    def update_subscription
      render json: update_subscription(valid_update_result_subscription_params)
    end

    def destroy_subscription
      render json: cancel_subscription(valid_destroy_result_subscription_params)
    end




    



    def show #returns a users results, like {"result_name1": [result_id1, result_id2, result_id3, ...result_idN]}
        render json: return_grouped_user_results
    end

    def create
        render json: save_results(user_result_params)
    end

    def destroy
        #destruirlos por nombre = "" where user_id = current_user ?
        render json: destroy_user_result(user_result_delete_params)
    end

    private
    
    def user_result_params
      params.permit({:results => []}, :name)
    end

    def user_result_delete_params
      params.require(:results).permit(:name)
    end

    def valid_show_results_values_params
      params.require(:name)
    end




    def valid_delete_stored_result_params
      params.require(:name)
    end



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
