 module RequestsHelper

    def transform_date_format(date)
        Time.at(date.to_i/1000).strftime("%Y-%m-%d") #Need to divide the MomentJS date  by 1000 to get the correct one.
    end

    def filter_results(params)

      @param_data = Hash.new
      @param_data.update(params) { |key, value| value.to_s }
   
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

      @param_data.each_pair do |key, val|
         @to_send.push(@param_json_routes[key.to_sym]) unless val.blank?
      end

      @query_result = @to_send.reduce(Result) { |prev, curr| prev.send("where", curr) }

    end
    
end