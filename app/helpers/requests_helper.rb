 module RequestsHelper
   require 'json'
    def transform_date_format(date)
        Time.at(date.to_i/1000).strftime("%Y-%m-%d") #Need to divide the MomentJS date  by 1000 to get the correct one.
    end

    def filter_results(parameters)
      @param_data = Hash.new
      #TODO fix deprecated to_hash
      parameters.each_pair {|k, v| @param_data[k] = v.to_s} 
    #  @param_data.update(params) { |key, value| value.to_s }
   
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
                            selectedDate: ["value ->> 'FechaCreacion' LIKE ?", "#{transform_date_format(@param_data['selectedDate'])}%"]
                           }
      #buscar palabras clave lo hare despues creo, si no, es posible que me demore demasiado( o quizas deba hacer benchmarks?)

      @param_data.each_pair do |key, value|
         @to_send.push(@param_json_routes[key.to_sym]) unless value.blank?
      end

      result = Array.new

#esto se puede hacer mas rapido con un where del parametro 0 y luego send los demas sobre ese subconjunto y concatenarlos?
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

end