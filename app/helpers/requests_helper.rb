 module RequestsHelper
   require 'json'

  def day_in_milliseconds
    hours = 24
    minutes = 60
    seconds = 60
    thousand = 1000

    hours * minutes * seconds * thousand
  end

  
  def transform_date_format(date)
      Time.at(date.to_i/1000).strftime("%Y-%m-%d") #Need to divide the MomentJS date  by 1000 to get the correct one.
  end


  def filter_results(parameters)
    @param_data = Hash.new

    parameters.each_pair {|k, v| @param_data[k] = v.to_s} 

    if @param_data["organismoPublico"] == "*"
      @param_data["organismoPublico"] = ""
    end

    if @param_data["estadoLicitacion"] == "*"
      @param_data["estadoLicitacion"] = ""
    end 
    
    @to_send = Array.new
    
    
    @param_json_routes = {
                          codigoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoExterno' = ? ", @param_data['codigoLicitacion']],
                          estadoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoEstado' = ? ", @param_data['estadoLicitacion']],
                          organismoPublico: ["value -> 'Listado' -> 0 -> 'Comprador' ->> 'CodigoOrganismo' = ? ", @param_data['organismoPublico']],
                          rutProveedor: ["value -> 'Listado' -> 0 -> 'Items' -> 'Listado' -> 0 -> 'Adjudicacion' ->> 'RutProveedor' = ? ", @param_data['rutProveedor']],
                          
                          }
    if !@param_data['selectedDate'].blank?
      selected_day_unix_epoch = @param_data['selectedDate']
      #add_one_day_unix_epoch = @param_data['selectedDate'] + day_in_milliseconds
      next_day_unix_epoch = selected_day_unix_epoch.to_i + day_in_milliseconds

      selected_day = transform_date_format(selected_day_unix_epoch)
      next_day = transform_date_format(next_day_unix_epoch)

      @param_json_routes[:selectedDate] = ["value ->> 'FechaCreacion' > ? AND value ->> 'FechaCreacion' < ?", selected_day, next_day]
    end
    #buscar palabras clave lo hare despues creo, si no, es posible que me demore demasiado( o quizas deba hacer benchmarks?)

    @param_data.each_pair do |key, value|
        @to_send.push(@param_json_routes[key.to_sym]) unless value.blank?
    end

    result = Array.new

    #TODO: check if by using pluck I can reduce the footprint of this query 
    Result.in_batches do |batch|
      sub_result = @to_send.reduce(batch) {|prev, curr| prev.send("where", curr) }
                                                            .map { |obj| obj.as_json}
      result.concat sub_result
    end
    #fast_generate disables checking  for circles (I assume that's circular references? It mentions infinite looping in case an
    #object has one)
    render plain: JSON.fast_generate(result), content_type: "application/json"
  end



  def use_date_range(date)

  end

end