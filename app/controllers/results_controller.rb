class ResultsController < ApplicationController
    include ResultsHelper
    
    before_action :authenticate_user!
    before_action :valid_params?, only: [:create, :update, :destroy]

    def show
        @to_send = create_user_results_hash
        render json: @to_send
    end

    def create
        if valid_ids?(params[:results])
            save_results(params[:results])
        else
            render json: {"message": {"errors": ["Id(s) inválido(s)"] } }
        end
    end

    def destroy

    end

    private
    
    def valid_params?
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
