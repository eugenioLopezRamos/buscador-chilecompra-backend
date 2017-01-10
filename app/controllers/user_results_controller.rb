class UserResultsController < ApplicationController
    include UserResultsHelper
    
    before_action :authenticate_user!
    before_action :valid_ids?, only: [:create, :update]
    before_action :valid_show_results_values_params?, only: [:show_results_values]

    def show #returns a users results, like {"result_name1": [result_id1, result_id2, result_id3, ...result_idN]}
        render json: return_grouped_user_results
    end

    def show_stored_results_values # grabs a result_name (say, "myownresult"), fetches all current_user's results with name "myownresult"
                            # and returns the values so they can be shown in the frontend
        render json: return_user_result_values(valid_show_results_values_params?)
    end

    def create
        save_results(user_result_params)
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

    def valid_show_results_values_params?
        params.require(:name)
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
