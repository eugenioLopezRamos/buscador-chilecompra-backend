class RequestsController < ApplicationController
  include RequestsHelper
  require 'json'
  require 'redis'
  DEFAULT_ORDER_BY_FIELD = ["\'Listado\'", "\'0\'", "\'CodigoExterno\'"].freeze

  before_action :valid_get_info_params?, only: :get_info
  before_action :verify_correct_date_format, only: :get_info
  before_action :verify_valid_always_from?, only: :get_info
  before_action :verify_valid_offset_format, only: :get_info
  before_action :valid_get_misc_info_params?, only: :get_misc_info
  before_action :authenticate_user!

  def initialize
    @result_limit_amount = 200
  end

  def get_info
    string_params = stringify_param_values(params)
    remove_wildcards(string_params)
    result = filter_results(string_params, @result_limit_amount)
    # renders => {results: [{json1}, {json2}, ...{jsonN}], count: "200", limit: "200"}
    render plain: JSON.fast_generate(result), content_type: 'application/json'

  rescue ArgumentError => except
    render json: json_message_to_frontend(errors: except), status: 422
  end

  def get_misc_info
    # TODO: Make this a single request on the front end and a .each do block here
    if %w(estados_licitacion organismos_publicos).include?(params[:info])
      return render json: Redis.current.hgetall(params[:info])
    end

    raise ArgumentError, 'Parámetros inválidos'
  rescue ArgumentError => except
    render json: json_message_to_frontend(errors: except), status: 422
  end

  private

  def verify_correct_date_format
    # dates = unix epoch format
    dates = [params[:startDate], params[:endDate]]
    dates.each do |date|
      unless is_integer?(date)
        raise ArgumentError, 'Fecha en formato inválido, por favor intentar de nuevo.'
      end

      transformed_date = transform_date_format(date)
      # transformed date = "YYYY-MM-DD")
      split_date = transformed_date.split('-')

      return transformed_date if Date.valid_date? *split_date.map(&:to_i)

      raise ArgumentError, 'Fecha en formato inválido, por favor intentar de nuevo.'
    end
  end

  def verify_valid_offset_format
    offset = params[:offset]
    offset_value = offset
    offset_value = 0 unless offset_value # || offset_value.empty?

    unless is_integer?(offset_value)
      raise ArgumentError, 'Offset inválido (Debe ser número entero)'
    end
    offset
  end

  def verify_valid_always_from?
    values = [params[:alwaysFromToday], params[:alwaysToToday]]
    values.each do |value|
      unless is_boolean? value
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

  def valid_get_info_params?
    # TODO: Make these required
    params.permit(
      :codigoLicitacion, :estadoLicitacion,
      :organismoPublico, :palabrasClave,
      :rutProveedor,
      :startDate, :alwaysFromToday,
      :endDate, :alwaysToToday,
      :offset,
      order_by: [
        :order,
        fields: []
      ]
    )
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
  end

  def valid_get_misc_info_params?
    params.require(:info)

  rescue ActionController::ParameterMissing, ActionController::ParameterMissing
    render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
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
