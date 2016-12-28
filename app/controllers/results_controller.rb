class ResultsController < ApplicationController
    before_action :authenticate_user!
    before_action :valid_params?, only: [:create, :update, :destroy]


    def show
    end

    def create
        @results = params[:results]
        @messages = Hash.new

        if valid_ids?(@results)
            
            @results.each do |r|
            
                new_entry = UserResult.create(user_id: current_user.id, result_id: r)
                if new_entry.save
                    @messages[r] = true
                else
                    @messages[r] = false
                end
            end

            #puts successfully recorded ids on successful
            #and failed ids on failed

            successful = Array.new
            failed = Array.new

            @messages.keys.map do |k|
                if @messages[k]
                    successful.push(k)
                else
                    failed.push(k)
                end
            end

            render json: {"message": {"successful": successful,
                                        "failed": failed}}
        else
            render json: {"message": "Id(s) inválido(s)"}
        end


    end

    # def update #Unneeded, this is just a "symlink" of result_id <=> user_id
    # end

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
