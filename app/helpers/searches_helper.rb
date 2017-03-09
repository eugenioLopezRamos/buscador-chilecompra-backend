module SearchesHelper

  def show_searches(user)
    searches = user.searches.pluck(*show_fields)
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
    return json_message_to_frontend(info: {"guardado con éxito": @successful.keys},
                                    errors: {"repetidos": @not_uniq.keys, "errores": @errors.keys },
                                    extra: {searches: show_searches(current_user)} ) 
  end

  def update_search(search)
    current_user.searches
                .find_by(name: search[:searchName])
                .update_attributes(value: search[:newValues], name: search[:searchName])
    
    return json_message_to_frontend(info:{"Modificado exitosamente": [search[:searchName]]},
                                    extra: {searches: show_searches(current_user)})

    rescue ActiveRecord::ActiveRecordError
      return json_message_to_frontend(errors: "Error al guardar cambios, por favor intentalo de nuevo"), status: 500
  end

  def destroy_search(search)
    id = search[:id]

    search = Search.find_by(user_id: current_user.id, id: id)
    name = search.name

    if search.destroy
      return json_message_to_frontend(
                                      info: {"Borrado exitosamente": [name]}, 
                                      extra: {searches: show_searches(current_user)}
                                      )
    else
      return json_message_to_frontend(
                                      errors:{"Fallido": [name]},
                                      extra: {searches: show_searches(current_user)}
                                      ), status: 500
  
    end
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