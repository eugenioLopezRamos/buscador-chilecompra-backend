class RequestsController < ApplicationController
  include RequestsHelper
  require 'json'
  require 'redis'
  DEFAULT_ORDER_BY_FIELD = ["\'Listado\'", "\'0\'", "\'CodigoExterno\'"].freeze

  before_action :valid_get_info_params?, only: :get_info
  before_action :valid_get_misc_info_params?, only: :get_misc_info
  before_action :authenticate_user!

  def initialize
    @result_limit_amount = 200
  end

  def get_info
    verify_correct_date_format(params[:startDate], params[:endDate])
    verify_valid_always_from?(params[:alwaysFromToday], params[:alwaysToToday])
    verify_valid_offset_format(params[:offset])
    # TODO: add verify_valid_order here

    result = filter_results(params, @result_limit_amount)

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

  def verify_correct_date_format(*dates)
    # dates = unix epoch format
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

  def verify_valid_offset_format(offset)
    offset_value = offset
    offset_value = 0 unless offset_value # || offset_value.empty?

    unless is_integer?(offset_value)
      raise ArgumentError, 'Offset inválido (Debe ser número entero)'
    end
    offset
  end

  def verify_valid_always_from?(*values)
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
end
