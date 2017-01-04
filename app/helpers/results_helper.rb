module ResultsHelper

    def save_results(results)
        
        @messages = Hash.new
        results.each do |r|
            begin        
                new_entry = UserResult.create(user_id: current_user.id, result_id: r)
                #puts successfully recorded ids on successful
                #and failed ids on failed
                if new_entry.save
                    @messages[r] = true
                else
                    @messages[r] = false
                end
                rescue ActiveRecord::RecordNotUnique
                @messages[r] = false  
            end     
        end

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
    end

    # TODO: refactor this method...
    def return_grouped_user_results
        #returns JSON of UserResults of current_user grouped by UserResult.name
        # so => {"myresultname": [id1, id2, id3...idN] }

        #get all the Results associated with current_user, as an array
        # a result is ["name", "id"], so @names will be [name1, name2, name3....]
        @resp = current_user.results.pluck("name", "id")

        #gets only each unique name, which we will use to group
        @names = @resp.map {|result| result[0]}.uniq

        #Make @names.length amount of arrays, where each array[n] has the results corresponding to @names[n]
        @each_name_array = @names.map do |name|
            @resp.select { |value| value[0] == name}
        end

        #As each name_results_arrays is an array of results ["nameXXXX", "1111", "nameYYYY", "1234"...]
        #map each array, then map each subarray and return subarray[1] (that is, the id of the name: id pair)
        @resp2 = @each_name_array.map do |array|
            array.map {|subarray| subarray[1]}
        end
        # So, this returns all the ids corresponding to each name (@resp2[n] are the results corresponding to @names[n])

        #make a hash where each item of @names is a key and each array of @resp2 (its ids) are the value
        @names.each_with_index.reduce(Hash.new) do |prev, (curr, index)| 
            prev[curr] = @resp2[index.to_i]
            prev
        end
         
    end

end