module UserResultsHelper
  #TODO: change the {"message"....} for the json_message_to_frontend method of ApplicationHelper


    # TODO: refactor this method...
    # check if it can be made easier with similar performance by using SQL group by in ActiveRecord
    def return_grouped_user_results
        #returns JSON of UserResults of current_user grouped by UserResult.name
        # so => {"myresultname": [id1, id2, id3...idN] }
        @response = Hash.new
        #get all the Results associated with current_user, as an array
        # a result is ["name", "id"], so @names will be [name1, name2, name3....]
        @resp = current_user.results.pluck("stored_group_name", "id")

        #gets only each unique name, which we will use to group
        @names = @resp.map {|result| result[0]}.uniq

        # #Make @names.length amount of arrays, where each array[n] has the results corresponding to @names[n]
        # @each_name_array = @names.map do |name|
        #     @resp.select { |value| value[0] == name}
        # end

        # #As each name_results_arrays is an array of results ["nameXXXX", "result_id_1", "nameYYYY", "result_id1234"...]
        # #map each array, then map each subarray and return subarray[1] (that is, the id of the name: id pair)
        # @resp2 = @each_name_array.map do |array|
        #     array.map {|subarray| subarray[1]}
        # end
        # # So, this returns all the ids corresponding to each name (@resp2[n] are the results corresponding to @names[n])

        # #make a hash where each item of @names is a key and each array of @resp2 (its ids) are the value
        # @names.each_with_index.reduce(Hash.new) do |prev, (curr, index)| 
        #     prev[curr] = @resp2[index.to_i]
        #     prev
        # end

        @names.map do |name|
          @response[name] = @resp.select {|value| value[0] === name}
                                 .map {|value| value[1]}
        end

        @response

    end

    def return_user_result_values(name)
        #returns an array with ids [2, 7, 18, ..., N]
        user_results = current_user.results.where("stored_group_name = ?", name).pluck("result_id")
        #find all results with ids in user_results                  
        Result.where(id: user_results).map { |element| element.to_json}
    end

    # def create_stored_result(parameters)
    #   @result_ids = parameters[:results]
    #   @name = parameters[:name]
    #   #returns a hash with info about what happened
    #   @message = current_user.store_results(@result_ids, @name)
    #   json_message_to_frontend(info: @message[:successful], errors: @message[:failed])
    # end

    def update_stored_result parameters
      @result_id = parameters[:update_subscription][:result_id]
      @name = parameters[:update_subscription][:name]
      
      current_user.update_stored_result(@result_id, @name)
    end

    def delete_stored_result name
      current_user.delete_stored_result name
    end










    def save_results(data)

        @successful = Hash.new   
        @failed = Hash.new
        @not_uniq = Hash.new

        data["results"].each do |r|
            begin        
                new_entry = UserResult.create(user_id: current_user.id, result_id: r, stored_group_name: data["name"])
                #puts successfully recorded ids on successful
                #and failed ids on failed
                if new_entry.save
                    @successful[r] = true
                else
                    @failed[r] = true
                end
                rescue ActiveRecord::RecordNotUnique
                    @not_uniq[r] = true
            end     
        end

       json_message_to_frontend(info: {"guardado con exito": @successful.keys},
                                errors: {"repetidos": @not_uniq.keys, "errores": @failed.keys})
                                              
    end

    def destroy_user_result(result)
        @successful = 0
        @errors = 0
        to_destroy = UserResult.where("user_id = ? AND stored_group_name = ?", current_user.id, result[:name])
        to_destroy.each do |record|
          begin
            record.destroy
            @successful += 1 
          rescue ActiveRecord::ActiveRecordError => e
            @errors += 1
          end
        end

       return {"message": {"info": {"eliminados": @successful},
                           "errors": @errors
                           },
               "results": return_grouped_user_results }
    end

    def create_subscription(subscription_info)
      @result = subscription_info[:result_id]
      @name = subscription_info[:name]
      # #if the user has stored the result, modify it (set subscribed => true and subscription_name => @name)
      # if current_user.has_stored_result? @result
      #   action = "subscribe_to_result"
      #   return attempt_subscription(action, @result, @name)
      # end
      #else, if user hasn't stored the result, create it and subscribe to it
      action = "create_and_subscribe_to_result"
      return attempt_subscription(action, @result, @name)
    end

    def update_subscription(parameters)
      @result = parameters[:create_subscription][:result_id]
      @name = parameters[:create_subscription][:name]

      if current_user.update_result_subscription(@result, @name)
        return json_message_to_frontend(error: "Error al actualizar la suscripción")#{"message": {"error": "Error al actualizar la suscripción"}}
      end

      return json_message_to_frontend(error: "Error al actualizar la suscripción")

      rescue ActiveRecord::ActiveRecordError
        return json_message_to_frontend(errors: "Error al actualizar la suscripción")
    end

    def cancel_subscription(parameters)
      @result = parameters[:cancel_subscription][:result_id]

      if current_user.cancel_result_subscription @result_id
        return json_message_to_frontend(errors: "Suscripción cancelada exitosamente")
      end

      return json_message_to_frontend(errors: "No se pudo cancelar la suscripción")

      rescue ActiveRecord::ActiveRecordError
        return json_message_to_frontend(errors: "Error al cancelar la suscripción")
    end


















    private

    def attempt_subscription(action, result, name)
      #check if the User model responds to this method, and if it does, call it with params then try to save the updated value
      if current_user.respond_to(action) && current_user.send(action, result, name).save
        return json_message_to_frontend(info: "Suscrito exitosamente")
      end
      #if ^ fails, rolldown to fail case
      return json_message_to_frontend(errors: "Error al guardar el resultado")
      #rescue in case activerecord raises
      rescue ActiveRecord::ActiveRecordError
        return json_message_to_frontend(errors: "Error al guardar el resultado")
    end

end