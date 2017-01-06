module SearchesHelper

  def show_searches
    searches = current_user.searches.pluck(*show_fields)
    hashify.(show_fields, 0, searches, Hash.new).delete_if {|k, v| v == [nil]}
  end


  def create_search(search)
    #TODO: just change the hashes to arrays probably.
    @successful= Hash.new
    @not_uniq = Hash.new
    @errors = Hash.new
      begin
        new_search = current_user.searches.create(value: search[:value], name: search[:name])
        if new_search.save
          @successful[search[:name]] = true
        else
          @errors[search[:name]] = true
        end
      rescue ActiveRecord::RecordNotUnique
        @not_uniq[search[:name]] = true
      end
    return {"message": {"info": {"guardado con exito": @successful.keys} ,
                               "errors": {"repetidos": @not_uniq.keys, "errores": @errors.keys}}
                  }
  end

  def update_search(search)
    to_update = current_user.searches.find_by(name: search[:name])
    to_update.update_attributes(value: search[:value], name: search[:name])
    
    rescue ActiveRecordError => e
      @messages["error"] = e 
  end

  def destroy_search(search)
    id = search[:id]

    search = Search.find_by(user_id: current_user.id, id: id)
    name = search.name
    #TODO: This json format is ugly....
    if search.destroy
      return {
              "message": {
                          "info": {
                                    "Borrado exitosamente": [name]
                                    } 
                          },
              "searches": show_searches
              }
    else
      return {
              "message": {
                          "errors": {
                                    "Fallido": [name]
                                    } 
                          },
              "searches": show_searches

              }
    
    end
    #TODO: rescue Devise::AuthenticationError (or however it's called)
    #rescue Devise::AuthError
    # return {"message": {"errors": {"Error": "Credenciales inválidas, por favor ingresa"}}}
    #  
  end

  private
  def show_fields
    ["name", "value", "id"]
  end

  def hashify
      #TODO: Document this in detail. TL;DR => makes a hash like {"name": [name1, name2, name3...], "value": [{value1...}, {value2...}], "id":[id1, id2, id3...]}
     ->(*show_fields, start_index, plucked_array, new_hash) {

        len = show_fields.flatten.length
        batch = plucked_array.flatten.slice(start_index, len)

        show_fields.flatten.each_with_index do |key, i|
          if !new_hash[key]
            new_hash[key] = Array.new.push(batch[i])
          else
            new_hash[key] = new_hash[key].push(batch[i])
          end
        end
        new_index = start_index + len

        if new_index >= plucked_array.flatten.length
          return new_hash
        end
        hashify.(show_fields, new_index, plucked_array, new_hash)
     }
      
  end

end