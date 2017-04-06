# Misc functions use for requests controller including logic
module RequestsHelper
  def day_in_milliseconds
    hours = 24
    minutes = 60
    seconds = 60
    thousand = 1000
    hours * minutes * seconds * thousand
  end

  # TODO: move away from here!
  def transform_date_format(date)
    Time.at(date.to_i / 1000).strftime('%Y-%m-%d') # Need to divide the MomentJS date  by 1000 to get the correct one.
  end

  def filter_results(parameters, limit)
    @json_param_routes = get_json_param_routes(parameters)
    @to_send = prepare_send_chain(parameters, @json_param_routes)
    dates = determine_dates(parameters)

    filtered_by_palabras_clave = filter_by_palabras_clave(dates, parameters['palabrasClave'])
    #Calculating results twice, need some way to avoid this
    total_results = get_total_results_amount(filtered_by_palabras_clave,
                                             @to_send)

    offset = calculate_offset(parameters['offset'], total_results[:count], limit)
    sorting = create_order_by(parameters['order_by'])

    sorted_result = limit_and_sort_results(total_results[:values],
                                           offset,
                                           limit,
                                           sorting)

    { values: sorted_result, count: total_results[:count], limit: limit, offset: offset }
  end

  def stringify_param_values(parameters)
    param_data = {}
    parameters.each_pair { |k, v| param_data[k] = v.to_s }
  end

  def remove_wildcards(parameters)
    if parameters['organismoPublico'] == '*' || !parameters['organismoPublico']
      parameters['organismoPublico'] = ''
    end

    if parameters['estadoLicitacion'] == '*' || !parameters['estadoLicitacion']
      parameters['estadoLicitacion'] = ''
    end
    parameters['offset'] = 0 unless parameters['offset']
    # see what to do wth order_by....
    parameters['order_by'] = parameters['order_by']
    parameters
  end

  def prepare_send_chain(parameters, json_routes)
    to_send = []
    parameters.each_pair do |key, value|
      to_send.push(json_routes[key.to_sym]) unless value.blank? || json_routes[key.to_sym].nil?
    end
    to_send
  end

  def get_total_results_amount(results, query_array)
    return {values: results, count: results.length } if query_array.empty?
    values = query_array.reduce(results) { |acc, elem| acc.send('where', elem) }
    count = values.length
    {values: values, count: count}
  end

  def get_latest_results_per_ids(start_date, end_date)
    latest_result_ids_per_codigo_externo = Result.latest_entry_per_codigo_externo(start_date, end_date)
                                                 .sort { |a, z| a <=> z }
    Result.where(id: latest_result_ids_per_codigo_externo)
  end

  def limit_and_sort_results(results, offset, limit, sorting)
    # here I get the latest, even if no modifications where made so I might end up with a codigoLicitacion
    # that was entered @ 9AM 'missing' since it will only show the latest(for example, at 11 AM)
    results.order(sorting)
           .offset(offset)
           .limit(limit)
           .map(&:as_json)
  end

  def determine_dates(parameters)
    # From the frontend dates come in unix epoch format,
    # which becomes YYYY-MM-DD  @ 00:00 AM
    # So, to get the end_date complete we need to add one more day_in_milliseconds
    # (if we want all results up to 2017-01-25, we need to set end_date to 27-01-26
    # so we'll get all results with date LESS than 2017-01-26 @ 00:00 AM

    # Javascript time is ruby time * 1000
    if parameters['alwaysFromToday'] || parameters['alwaysToToday']
      return dates_with_always_today(parameters)
    end

    start_date = transform_date_format(parameters['startDate'])
    end_date_next_day = parameters['endDate'].to_i + day_in_milliseconds

    end_date = transform_date_format(end_date_next_day)

    { start_date: start_date, end_date: end_date }
  end

  def dates_with_always_today(parameters)
    # If alwaysFromToday == "true" then we use defaults for BOTH dates
    return default_dates if parameters['alwaysFromToday'] == 'true'
    # if alwaysToToday, use the default only for end_date(start_date gets its entered value)
    {
      start_date: transform_date_format(parameters['startDate']),
      end_date: default_dates[:end_date]
    }
  end

  def default_dates
    {
      start_date: transform_date_format(Time.zone.now.to_i * 1000),
      end_date: transform_date_format(Time.zone.now.to_i * 1000 +
                                      day_in_milliseconds)
    }
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
    return 0 if offset.to_i < 0
    if offset.to_i >= results_amount
      # these are integers, so the decimals are truncated -> becomes the last chunk of results
      new_offset = results_amount / limit
      new_offset *= limit
      return new_offset
    end
    offset.to_i
  end

  def create_order_by(order_by)
    # TODO: Check if vulnerable to sql injection :(

    # order_by = {fields: [...], order: "descending || ascending" }
    fields = if order_by['fields'].empty?
               RequestsController::DEFAULT_ORDER_BY_FIELD
             else
               order_by['fields'].map do |element|
                 if is_integer? element
                   element.to_s
                 else
                   ActiveRecord::Base.connection.quote(element)
                 end
               end
             end

    # TODO: Refactor this....

    if fields.length == 1
      order_by_query = 'value ->> ' + fields[0]
    elsif fields.length == 2
      order_by_query = 'value -> ' + fields[0] + ' ->> ' + fields[1]
    elsif fields.length == 3
      order_by_query = 'value -> ' + fields[0] + ' -> ' + fields[1] + ' ->> ' + fields[2]
    else
      route = fields.slice(0, fields.length - 2).join(' -> ')
      desired_value = fields.slice(fields.length - 1, 1)[0]
      full_route = 'value -> ' + route + ' ->> ' + desired_value
      order_by_query = full_route
    end

    order_by_query += ' DESC' if order_by['order'] == 'descending'

    order_by_query += ' ASC' if order_by['order'] == 'ascending'
    order_by_query
  end

  def filter_by_palabras_clave(dates, palabras_clave)
    start_date = dates[:start_date]
    end_date = dates[:end_date]

    results = get_latest_results_per_ids(start_date, end_date)
    return results if palabras_clave.nil?

    palabras_clave_array = palabras_clave.split(' ')
    return results if palabras_clave_array.empty?

    palabras_clave_array = palabras_clave_array.map { |palabra| "%#{palabra}%" }

    palabras_amount = palabras_clave_array.length

    descripcion_query_base = "LOWER(value -> 'Listado' -> 0 ->> 'Descripcion') LIKE LOWER(?)"
    nombre_query_base = "LOWER(value -> 'Listado' -> 0 ->> 'Nombre') LIKE LOWER(?)"

    @descripcion_query = descripcion_query_base
    @nombre_query = nombre_query_base

    if palabras_amount > 1
      (palabras_amount - 1).times do
        @descripcion_query = @descripcion_query + ' AND ' + descripcion_query_base
      end

      (palabras_amount - 1).times do
        @nombre_query = @nombre_query + ' AND ' + nombre_query_base
      end
    end

    # Twice, since its one palabras_clave_array for @descripcion_query and another for @nombre_query
    results.where("#{@descripcion_query} OR #{@nombre_query}", *palabras_clave_array, *palabras_clave_array)
  end
end
