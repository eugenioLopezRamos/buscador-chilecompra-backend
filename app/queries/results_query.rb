require "#{Rails.root}/app/queries/modules/results_query/results_query_helpers.rb"
require "#{Rails.root}/app/queries/modules/results_query/results_query_scrubbers.rb"
# TODO: Maybe make the filters more modular? like partial application of
# @filter_chain (including a reader so you can know what filters are there and
# in what position etc)
# Misc functions use for requests controller including logic
class ResultsQuery
  include ResultsQueryHelper
  include ResultsQueryScrubber

  def initialize(parameters, result_limit_amount)
    remove_wildcards(parameters)
    palabras_clave_to_array(parameters)
    @parameters = parameters
    @limit = result_limit_amount
    @filter_chain = prepare_filter_chain
    @dates = determine_dates(parameters)
  end

  def filter
    total_results = get_total_results(@dates)
    filtered_by_palabras_clave = filter_by_palabras_clave(total_results, @parameters['palabrasClave'])

    offset = calculate_offset(@parameters['offset'], filtered_by_palabras_clave.length, @limit)
    sorting = create_order_by(@parameters['order_by'])

    sorted_result = limit_and_sort_results(filtered_by_palabras_clave, offset, @limit,
                                           sorting)
    { values: sorted_result, count: filtered_by_palabras_clave.length, limit: @limit, offset: offset }
  end

  def prepare_filter_chain
    # Prepares filter for codigoLicitacion, organismoPublico, rutProveedor
    # estadoLicitacion (which are fields in the "value" column (JSON))
    json_routes = get_json_param_routes(@parameters)
    @filter_chain = []
    @parameters.each_pair do |key, value|
      @filter_chain.push(json_routes[key.to_sym]) unless value.blank? || json_routes[key.to_sym].nil?
    end
    @filter_chain
  end

  def get_total_results(dates)
    results = Result.get_latest_results_per_ids(dates[:start_date], dates[:end_date])
    return results if @filter_chain.empty?
    @filter_chain.reduce(results) { |acc, elem| acc.send('where', elem) }
  end

  def limit_and_sort_results(results, offset, limit, sorting)
    # here I get the latest, even if no modifications where made so I might end up with a codigoLicitacion
    # that was entered @ 9AM 'missing' since it will only show the latest(for example, at 11 AM)
    results.order(sorting)
           .offset(offset)
           .limit(limit)
           .map(&:as_json)
  end

  def filter_by_palabras_clave(results, palabras_clave)
    return results if palabras_clave.empty?
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
