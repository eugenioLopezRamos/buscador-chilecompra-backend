class ResultsController < ApplicationController
    include ResultsHelper
    
    before_action :authenticate_user!
#    before_action :valid_params?, only: [:create, :update, :destroy]

    def show
        render json: return_grouped_user_results
    end

    def create
        if valid_ids?(result_params)
            save_results(result_params)
        else
            render json: {"message": {"errors": ["Id(s) inválido(s)"] } }
        end
    end

    def destroy
        #destruirlos por nombre = "" where user_id = current_user ?
    end

    private
    
    def result_params
        params.permit(:results => [])
    end

    def valid_ids?(ids_array)
        new_arr = ids_array.map {|id| id.to_i}
        if new_arr != ids_array
            return false
        else
            return true
        end
    end

end
