# Misc helper functions for SearchesController
module SearchesHelper
  def show_searches(user)
    searches = user.searches.pluck(*show_fields)
    hashify.call(show_fields.flatten, 0, searches.flatten, {}).delete_if { |_key, value| value == [nil] }
  end

  def populate_response(response, search_name)
    new_search = current_user.searches.create(value: search_name, name: search_name)
    new_search.save ? response[:successful].push(search_name) : response[:errors].push(search_name)
  rescue ActiveRecord::RecordNotUnique
    response[:not_uniq].push(search_name)
  end

  private

  def show_fields
    %w(name value id)
  end

  def hashify
    # TODO: Document this in detail. TL;DR => makes a hash like {"name": [name1, name2, name3...], "value": [{value1...}, {value2...}], "id":[id1, id2, id3...]}
    lambda do |*show_fields, start_index, plucked_array, new_hash|
      len = show_fields.flatten.length
      batch = plucked_array.flatten.slice(start_index, len)

      show_fields.flatten.each_with_index do |key, i|
        new_hash[key] = if !new_hash[key]
                          [].push(batch[i])
                        else
                          new_hash[key].push(batch[i])
                        end
      end
      new_index = start_index + len

      return new_hash if new_index >= plucked_array.flatten.length
      hashify.call(show_fields, new_index, plucked_array, new_hash)
    end
  end
end
