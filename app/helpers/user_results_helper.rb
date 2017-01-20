module UserResultsHelper
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
        @names.map do |name|
          @response[name] = @resp.select {|value| value[0] === name}
                                 .map {|value| value[1]}
        end

        @response

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

    def create_subscription(subscription_info)
      @result = subscription_info[:result_id]
      @name = subscription_info[:name]

      action = "create_and_subscribe_to_result"
      return attempt_subscription(action, @result, @name)
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