class ResultsController < ApplicationController
    include ResultsHelper
    
    before_action :authenticate_user!
    before_action :valid_ids?, only: [:create, :update, :destroy]

    def show
        render json: return_grouped_user_results
    end

    def create
        save_results(result_params)
    end

    def destroy
        #destruirlos por nombre = "" where user_id = current_user ?
    end

    private
    
    def result_params
        params.permit({:results => []}, :name)
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
