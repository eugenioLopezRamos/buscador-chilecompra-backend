 module RequestsHelper

  def day_in_milliseconds
    hours = 24
    minutes = 60
    seconds = 60
    thousand = 1000

    hours * minutes * seconds * thousand
  end

  #TODO: move away from here!
  def transform_date_format(date)
      Time.at(date.to_i/1000).strftime("%Y-%m-%d") #Need to divide the MomentJS date  by 1000 to get the correct one.
  end


  def filter_results(parameters, limit)
    @param_data = stringify_param_values(parameters)
    @json_param_routes = get_json_param_routes(@param_data)
    @to_send = prepare_send_chain(@param_data, @json_param_routes)
#ver to_send no funciona


    start_date = determine_dates(@param_data)[:start_date]
    end_date = determine_dates(@param_data)[:end_date]

    latest_results_per_ids = get_latest_results_per_ids(start_date, end_date)

    total_results_amount = get_total_results_amount(latest_results_per_ids, @to_send)

    offset = calculate_offset(@param_data["offset"], total_results_amount, limit)
    sorting = create_order_by(@param_data["order_by"])

    filtered_by_palabras_clave = filter_by_palabras_clave(latest_results_per_ids, @param_data["palabrasClave"])
    
    sorted_result = get_result_from_query(filtered_by_palabras_clave, @to_send, offset, limit, sorting)

    {values: sorted_result, count: total_results_amount, limit: limit, offset: offset}

  end

  def stringify_param_values(parameters)
    param_data = Hash.new

    parameters.each_pair {|k, v| param_data[k] = v.to_s} 

    if param_data["organismoPublico"] == "*" ||!param_data["OrganismoPublico"]
      param_data["organismoPublico"] = ""
    end

    if param_data["estadoLicitacion"] == "*" || !param_data["estadoLicitacion"]
      param_data["estadoLicitacion"] = ""
    end

    if !param_data["offset"]#.nil? || param_data["offset"].empty?
      param_data["offset"] = 0
    end
    #see what to do wth order_by....
    param_data["order_by"] = parameters["order_by"]
    param_data
  end

  def prepare_send_chain(parameters, json_routes)

    to_send = Array.new

    parameters.each_pair do |key, value|
        to_send.push(json_routes[key.to_sym]) unless value.blank? || json_routes[key.to_sym].nil?
    end
    to_send

  end

  def get_total_results_amount(results, query_array)
    query_array.reduce(results) {|prev, curr| prev.send("where", curr) }.count
  end

  def get_latest_results_per_ids(start_date, end_date)
    latest_result_ids_per_codigo_externo = Result.latest_entry_per_codigo_externo(start_date, end_date)
                                                                                  .sort {|a,z| a <=> z }
    Result.where(id: latest_result_ids_per_codigo_externo)
  end

  def get_result_from_query(results, query_array, offset, limit, sorting)


    # here I get the latest, even if no modifications where made so I might end up with a codigoLicitacion
    # that was entered @ 9AM 'missing' since it will only show the latest(for example, at 11 AM)
    
   # offset_val = offset - 1 < 0 ? 0 : offset - 1
   # debugger unless offset != 200
   #debugger
   #offset_val = offset == 0 ? 0 : offset + 1 

   if query_array.empty?
    # if offset_val != 0
    #   debugger
    # end

    #es el .order el que me caga...


     return results.order(sorting)
                   .offset(offset)
                   .limit(limit)
                   .map {|obj| obj.as_json}
  end

   val = query_array.reduce(results) {|prev, curr| prev.send("where", curr)}
                        .order(sorting)
                        .offset(offset)
                        .limit(limit)
                        .map { |obj| obj.as_json}       
  end


  def determine_dates(parameters)
    # From the frontend dates come in unix epoch format, 
    # which becomes YYYY-MM-DD  @ 00:00 AM
    # So, to get the end_date complete we need to add one more day_in_milliseconds
    # (if we want all results up to 2017-01-25, we need to set end_date to 27-01-26
    # so we'll get all results with date LESS than 2017-01-26 @ 00:00 AM
    
    #Javascript time is ruby time * 1000
    default_start_date = transform_date_format(Time.zone.now.to_i * 1000)
    default_end_date = transform_date_format(Time.zone.now.to_i * 1000 + day_in_milliseconds)

    dates = {start_date: default_start_date,
             end_date: default_end_date}
    #If alwaysFromToday == "true" then we use defaults for BOTH dates
    if parameters["alwaysFromToday"] == "true"
      return dates
    end
    #if alwaysToToday, use the default only for end_date(start_date gets its entered value)
    if parameters["alwaysToToday"] == "true"
      dates[:start_date] = transform_date_format(parameters["startDate"])
      return dates
    end

    start_date = transform_date_format(parameters["startDate"])
    end_date_next_day = parameters["endDate"].to_i + day_in_milliseconds

    end_date = transform_date_format(end_date_next_day)

    dates = {start_date: start_date, end_date: end_date}
  end

  def get_json_param_routes(param_data)
    {
      codigoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoExterno' = ? ", param_data['codigoLicitacion']],
      estadoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoEstado' = ? ", param_data['estadoLicitacion']],
      organismoPublico: ["value -> 'Listado' -> 0 -> 'Comprador' ->> 'CodigoOrganismo' = ? ", param_data['organismoPublico']],
      rutProveedor: ["value -> 'Listado' -> 0 -> 'Items' -> 'Listado' -> 0 -> 'Adjudicacion' ->> 'RutProveedor' = ? ", param_data['rutProveedor']]
    }
  end

  def calculate_offset(offset, results_amount, limit)
    if offset.to_i < 0
      return 0
    end
    if offset.to_i >= results_amount
     # these are integers, so the decimals are truncated -> becomes the last chunk of results
     new_offset = results_amount / limit
     new_offset = new_offset * limit
     return new_offset
    end
    return offset.to_i
  end

  def create_order_by(order_by)
    #TODO: Check if vulnerable to sql injection

    #order_by = {fields: [...], order: "descending || ascending" }
    if order_by["fields"].empty?
      fields = RequestsController::DEFAULT_ORDER_BY_FIELD
    else
      fields = order_by["fields"].map do |element|
                  if is_integer? element
                    element.to_s
                  else
                    "'#{element.to_s}'"
                  end
              end
    end

    #TODO: Refactor this....         

    if fields.length == 1
      order_by_query = "value ->> " + fields[0]
    elsif fields.length == 2
      order_by_query = "value -> " + fields[0] + " ->> " + fields[1]
    elsif fields.length === 3
      order_by_query = "value -> " + fields[0] + " -> " + fields[1] + " ->> " + fields[2]
    else
      route = fields.slice(0, fields.length - 2).join(" -> ")
      desired_value = fields.slice(fields.length - 1, 1)[0]
      full_route = "value -> " + route + " ->> " + desired_value
      order_by_query = full_route

    end
  
    if order_by["order"] == "descending"
      order_by_query = order_by_query + " DESC"
    end

    if order_by["order"] == "ascending"
      order_by_query = order_by_query + " ASC"
    end
    order_by_query
  end

  def filter_by_palabras_clave(results, palabras_clave)
    if palabras_clave.nil?
      return results
    end

    palabras_clave_array = palabras_clave.split(" ")
    if palabras_clave_array.empty?
      return results
    end

    palabras_clave_array = palabras_clave_array.map{|palabra| "%#{palabra}%"}

    palabras_amount = palabras_clave_array.length

    descripcion_query_base = "value -> 'Listado' -> 0 ->> 'Descripcion' LIKE ?"
    nombre_query_base = "value -> 'Listado' -> 0 ->> 'Nombre' LIKE ?"

    @descripcion_query = descripcion_query_base
    @nombre_query = nombre_query_base

    if palabras_amount > 1
      (palabras_amount - 1).times do
        @descripcion_query = @descripcion_query + " AND " + descripcion_query_base
      end 

      (palabras_amount - 1).times do
        @nombre_query = @nombre_query + " AND " + nombre_query_base
      end 
    end
    
    #Twice, since its one palabras_clave_array for @descripcion_query and another for @nombre_query
    results.where("#{@descripcion_query} OR #{@nombre_query}", *palabras_clave_array, *palabras_clave_array)

  end


end