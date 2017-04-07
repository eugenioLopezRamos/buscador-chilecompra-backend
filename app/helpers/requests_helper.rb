# Misc functions use for requests controller including logic
module RequestsHelper
  def filter_results(parameters, limit)
    dates = determine_dates(parameters)

    total_results = get_total_results(dates, parameters)
    filtered_by_palabras_clave = filter_by_palabras_clave(total_results, parameters['palabrasClave'])

    offset = calculate_offset(parameters['offset'], filtered_by_palabras_clave.length, limit)
    sorting = create_order_by(parameters['order_by'])

    sorted_result = limit_and_sort_results(filtered_by_palabras_clave, offset, limit,
                                           sorting)

    { values: sorted_result, count: filtered_by_palabras_clave.length, limit: limit, offset: offset }
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

  def prepare_send_chain(parameters)
    json_routes = get_json_param_routes(parameters)
    to_send = []
    parameters.each_pair do |key, value|
      to_send.push(json_routes[key.to_sym]) unless value.blank? || json_routes[key.to_sym].nil?
    end
    to_send
  end

  def get_total_results(dates, parameters)
    results = get_latest_results_per_ids(dates[:start_date], dates[:end_date])
    query_array = prepare_send_chain(parameters)
    return results if query_array.empty?
    query_array.reduce(results) { |acc, elem| acc.send('where', elem) }
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
    if parameters['alwaysFromToday'] == 'true' || parameters['alwaysToToday'] == 'true'
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
    fields = order_by_fields(order_by['fields'])
    order_by_query = ''
    fields[0..-2].each { |field| order_by_query << " #{field} ->" }
    order_by_query << " #{fields[-1]} "
    order_by_query << 'DESC' if order_by['order'] == 'descending'
    order_by_query << 'ASC' if order_by['order'] == 'ascending'
    order_by_query
  end

  def order_by_fields(fields_array)
    return ['value'].concat RequestsController::DEFAULT_ORDER_BY_FIELD if fields_array.empty?
    fields = fields_array.map do |element|
      if integer? element
        element.to_s
      else
        ActiveRecord::Base.connection.quote(element)
      end
    end
    ['value'].concat fields
  end

  def filter_by_palabras_clave(results, palabras_clave_string)
    return results if palabras_clave_string.nil?
    palabras_clave = palabras_clave_string.split(' ')
    return results if palabras_clave.empty?

    palabras_clave.map! { |palabra| "%#{palabra}%" }
    @descripcion_query = palabras_clave_query_base.call('Descripcion')
    @nombre_query = palabras_clave_query_base.call('Nombre')
    # Twice, since its one palabras_clave_array for @descripcion_query and another for @nombre_query
    return results.where("#{@descripcion_query} OR #{@nombre_query}", *palabras_clave, *palabras_clave) if palabras_clave.length == 1

    (palabras_clave.length - 1).times do
      @descripcion_query << " AND #{palabras_clave_query_base.call('Descripcion')}"
      @nombre_query << " AND #{palabras_clave_query_base.call('Nombre')}"
    end
    results.where("#{@descripcion_query} OR #{@nombre_query}", *palabras_clave, *palabras_clave)
  end
end
