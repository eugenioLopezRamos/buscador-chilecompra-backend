# Misc helper functions for SearchesController
module SearchesHelper
  def show_searches(user)
    searches = user.searches.pluck(*show_fields)
    hashify.call(show_fields.flatten, 0, searches.flatten, {}).delete_if { |_key, value| value == [nil] }
  end

  def create_search(search)
    search_name = search[:name]
    response = { successful: [], not_uniq: [], errors: [] }
    begin
      new_search = current_user.searches.create(value: search_name, name: search_name)
      new_search.save ? response[:successful].push(search_name) : response[:errors].push(search_name)
    rescue ActiveRecord::RecordNotUnique
      response[:not_uniq].push(search_name)
    end
    response
  end

  def update_search(search)
    current_user.searches
                .find_by(name: search[:searchName])
                .update_attributes(value: search[:newValues], name: search[:searchName])

    return json_message_to_frontend(info: { "Modificado exitosamente": [search[:searchName]] },
                                    extra: { searches: show_searches(current_user) })

  rescue ActiveRecord::ActiveRecordError
    return json_message_to_frontend(errors: 'Error al guardar cambios, por favor intentalo de nuevo'), status: 500
  end

  def destroy_search(search)
    id = search[:id]

    search = Search.find_by(user_id: current_user.id, id: id)
    { successful?: search.destroy, name: search.name }
  end

  private

  def show_fields
    %w(name value id)
  end

  def hashify
    # TODO: Document this in detail. TL;DR
    # => makes a hash like
    # {"name": [name1, name2, name3...],
    #  "value": [{value1...}, {value2...}],
    #  "id":[id1, id2, id3...]
    #  }
    lambda do |*show_fields, start_index, plucked_array, new_hash|
      fields_length = show_fields.length
      batch = plucked_array.slice(start_index, fields_length)

      show_fields.each_with_index do |key, i|
        batch_value = batch[i]
        new_hash[key] = new_hash[key] ? new_hash[key].push(batch_value) : [].push(batch_value)
      end
      new_index = start_index + fields_length
      return new_hash if new_index >= plucked_array.length
      hashify.call(show_fields, new_index, plucked_array, new_hash)
    end
  end
end
