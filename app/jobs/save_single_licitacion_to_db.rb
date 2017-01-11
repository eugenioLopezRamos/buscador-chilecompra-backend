class SaveSingleLicitacionToDB
    @queue = :save_to_db

    def self.perform(licitacion)
        datos_lic = licitacion["Listado"]
        File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Intentando guardar #{datos_lic[0]['CodigoExterno']} a las #{Time.now()} \n" }

        result = Result.create(value: licitacion)
        #gets CodigoExterno to check for changes from the last version to the current one
        result_codigo_externo = licitacion["Listado"][0]["CodigoExterno"]
        previous_last_result_value = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", result_codigo_externo).last.value
        previous_last_result_id = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", result_codigo_externo).last.id

        if result.save
            File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Exito: Licitacion #{datos_lic[0]['CodigoExterno']} a las #{Time.now()} \n" }
            if result.value != previous_last_result_value #If the value of the licitacion changed....
                #get users subscribed to the result, who'll be notified of the change
                users = users_subscribed_to result_id
                # send this to a job queue so it gets added to user's notifications and added to the email newsletter send queue
                Resque.enqueue(LicitacionChangeEmailer, users)
                Resque.enqueue(AddLicitacionChangeToUserNotifications, users)    
            end
        else
            File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Fallo: Licitacion #{datos_lic[0]['CodigoExterno']} a las #{Time.now()} \n" }          
        end
    end

    def users_subscribed_to result_id
        #get all users that have a result saved that includes the one that was modified
        UserResult.in_batches.reduce(Array.new) do |accumulator, current|
            #get the user_ids of users with the result_id saved
            new_ids = current.where(result_id: result_id).pluck("user_id")
            accumulator.concat new_ids
        end
    end

end