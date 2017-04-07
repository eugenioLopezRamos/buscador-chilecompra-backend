require "#{Rails.root}/lib/licitacion_data.rb"
# Handles requests for info from outside
class RequestsController < ApplicationController
  require 'redis'
  DEFAULT_ORDER_BY_FIELD = ["\'Listado\'", "\'0\'", "\'CodigoExterno\'"].freeze
  RESULT_LIMIT_AMOUNT = 200
  before_action :valid_licitacion_data_params?, only: :licitacion_data
  before_action :verify_correct_date_format, only: :licitacion_data
  before_action :verify_valid_always_from?, only: :licitacion_data
  before_action :verify_valid_offset_format, only: :licitacion_data
  before_action :valid_chilecompra_misc_data_params?, only: :chilecompra_misc_data
  before_action :authenticate_user!

  def licitacion_data
    # string_params = stringify_param_values(params)
    # remove_wildcards(string_params)
    result = LicitacionData.new(params, RESULT_LIMIT_AMOUNT).filter
    # renders => {results: [{json1}, {json2}, ...{jsonN}], count: "200", limit: "200"}
    render json: result
  rescue ArgumentError => except
    render json: json_message(errors: except), status: 422
  end

  def chilecompra_misc_data
    # TODO: Make this a single request on the front end and a .each do block here
    if %w(estados_licitacion organismos_publicos).include?(params[:info])
      return render json: Redis.current.hgetall(params[:info])
    end

    raise ArgumentError, 'Parámetros inválidos'
  rescue ArgumentError => except
    render json: json_message(errors: except), status: 422
  end

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

  private

  def verify_correct_date_format
    # dates = unix epoch format
    dates = [params[:startDate], params[:endDate]]
    dates.each do |date|
      unless integer?(date)
        raise ArgumentError, 'Fecha en formato inválido, por favor intentar de nuevo.'
      end

      transformed_date = transform_date_format(date)
      # transformed date = "YYYY-MM-DD")
      split_date = transformed_date.split('-')

      return transformed_date if Date.valid_date?(*split_date.map(&:to_i))

      raise ArgumentError, 'Fecha en formato inválido, por favor intentar de nuevo.'
    end
  end

  def verify_valid_offset_format
    offset = params[:offset] ? params[:offset] : 0
    raise ArgumentError, 'Offset inválido (Debe ser núm entero)' unless integer?(offset)
    offset
  end

  def verify_valid_always_from?
    values = [params[:alwaysFromToday], params[:alwaysToToday]]
    values.each do |value|
      unless boolean? value
        raise ArgumentError, "Valor 'Siempre desde/siempre hasta' inválido (debe ser booleano)"
      end
    end
    true
  end

  def verify_valid_order(value)
    # TODO: Check the [:fields] value for
    # valid data (eg. check against an example object)
    return true if %w(descending ascending).include? value
    raise ArgumentError, "Orden debe ser 'ascending' (menor a mayor) o 'descending' (mayor a menor)"
  end

  def valid_licitacion_data_params?
    params.permit(
      :codigoLicitacion, :estadoLicitacion, :organismoPublico,
      :palabrasClave, :rutProveedor, :startDate, :alwaysFromToday,
      :endDate, :alwaysToToday, :offset,
      order_by: [:order, fields: []]
    )
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    render json: json_message(errors: 'Parámetros inválidos'), status: 422
  end

  def valid_chilecompra_misc_data_params?
    params.require(:info)

  rescue ActionController::ParameterMissing, ActionController::ParameterMissing
    render json: json_message(errors: 'Parámetros inválidos'), status: 422
  end

  def get_json_param_routes(param_data)
    {
      codigoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoExterno' = ? ", param_data['codigoLicitacion']],
      estadoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoEstado' = ? ", param_data['estadoLicitacion']],
      organismoPublico: ["value -> 'Listado' -> 0 -> 'Comprador' ->> 'CodigoOrganismo' = ? ", param_data['organismoPublico']],
      rutProveedor: ["value -> 'Listado' -> 0 -> 'Items' -> 'Listado' -> 0 -> 'Adjudicacion' ->> 'RutProveedor' = ? ", param_data['rutProveedor']]
    }
  end

  def palabras_clave_query_base
    ->(field_name) { return "LOWER(value -> 'Listado' -> 0 ->> #{ActiveRecord::Base.connection.quote(field_name)}) LIKE LOWER(?)" }
  end

  def default_dates
    {
      start_date: transform_date_format(Time.zone.now.to_i * 1000),
      end_date: transform_date_format(Time.zone.now.to_i * 1000 +
                                      day_in_milliseconds)
    }
  end
end
