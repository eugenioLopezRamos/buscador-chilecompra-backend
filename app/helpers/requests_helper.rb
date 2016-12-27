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

    # def build_query_string(params)

    #   @query_parameters = Array.new

    #   ################### CODIGO LICITACION
    #   @codigo_licitacion = params["codigoLicitacion"].to_s
    #   @query_parameters.push("codigo=" << @codigo_licitacion) unless @codigo_licitacion.blank?

    #   ################ ESTADO LICITACION
    #   @estado_licitacion = params["estadoLicitacion"].to_s
    #   if @estado_licitacion === "Todos"
    #     @estado_licitacion = ""
    #   end
    #   @query_parameters.push("estado=" << @estado_licitacion) unless @estado_licitacion.blank?

    #   ############# DATE
    #   @selected_date = transform_date_format.(params["selectedDate"])                                  
    #   @query_parameters.push("fecha=" << @selected_date) unless @selected_date.blank?

    #   ################ ORGANISMO PUBLICO
    #   @organismo_publico = params["organismoPublico"].to_s === "*" ? "" : params["organismoPublico"]
    #   @query_parameters.push("codigoOrganismo=" << @organismo_publico) unless @organismo_publico.blank?

    #   ############# RUT PROVEEDOR
    #   @rut_proveedor = params["rutProveedor"].to_s
    #   if !@rut_proveedor.blank?
    #     @info_proveedor = get_codigo_proveedor.(@rut_proveedor, @API_buscar_proveedores_uri)

    #     @codigo_proveedor = @info_proveedor["CodigoEmpresa"]
    #     @nombre_proveedor = @info_proveedor["NombreEmpresa"]
    #   end
    #   @query_parameters.push("CodigoProveedor=" << @codigo_proveedor) unless @codigo_proveedor.blank?
    #   @query_parameters.join("&")
    # end

    # def filter_palabras_clave(results, filter, type="list")
    #   #type can be list (all licitaciones) or single (a single licitacion, which has much more detail)
    #   case type
    #     when "list"
    #   orig_results = results
    #   new_results = JSON.parse(results)
    #   filter_string = Regexp.new(filter.downcase)
    #   # Here I could probably split the different words in regex groups and check against that. It might be a little slow though?

    #   filtered_listado = JSON.parse(orig_results)["Listado"].select { 
    #     |x| 
    #     if x["Nombre"].downcase.match(filter_string)
    #       x
    #     end
    #   }

    #   new_results["Cantidad"] = filtered_listado.length
    #   new_results["Listado"] = filtered_listado

    #   when "single"
    #       #### TODO
    #   end

    #   return new_results
    # end

    # def get_codigo_proveedor
    #   return Proc.new { 
    #     |proveedor, uri| 
    #     to_get = uri << proveedor << "&" << @API_key_uri
    #     to_get = URI(to_get)
    #     @response = Net::HTTP.get(to_get)
    #     @return_value = JSON.parse(@response)
    #     #binding.pry
    #     @return_value = @return_value["listaEmpresas"][0] # "listaEmpresas is a 1 length array, so [0] returns => {"CodigoEmpresa": "111", "NombreEmpresa": "abcd S.A"}
    #     @return_value
    #   } 
    # end
    
end