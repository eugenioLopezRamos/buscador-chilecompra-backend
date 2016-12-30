module SearchesHelper

  def show_searches
    searches = current_user.searches.pluck(*show_fields)
    hashify.(show_fields, 0, searches, Hash.new)
  end


  def create_search(search)
    @messages = Hash.new
      begin
        new_search = current_user.searches.create(value: search[:value], name: search[:name])
        if new_search.save
          @messages["info"] = "Resultado guardado exitosamente"
        end
      rescue ActiveRecord::RecordNotUnique
        @messages["error"] = "Nombre de resultado duplicado, por favor elige otro"
      end
    @messages
  end



  private
  def show_fields
    ["name", "value", "id"]
  end

  def hashify
      #TODO: Document this in detail. TLDR => makes a hash like {"name": [name1, name2, name3...], "value": [{value1...}, {value2...}], "id":[id1, id2, id3...]}
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