class RequestsController < ApplicationController
  include RequestsHelper
  require 'json'
  require 'redis'
  
  before_action :valid_get_info_params?, only: :get_info
  before_action :valid_get_misc_info_params?, only: :get_misc_info
  before_action :valid_entity_params?, only: :get_entity_data
  before_action :authenticate_request!, only: :show_hello

  def initialize
    @result_limit_amount = 200
  end

  def get_info
    
    verify_correct_date_format(params[:startDate], params[:endDate])
    verify_valid_always_from?(params[:alwaysFromToday], params[:alwaysToToday])
    verify_valid_offset_format(params[:offset])

    result = filter_results(params, @result_limit_amount)

    # renders => {results: [{json1}, {json2}, ...{jsonN}], count: "200", limit: "200"}
    render plain: JSON.fast_generate(result), content_type: "application/json"

    rescue ArgumentError => except
          render json: json_message_to_frontend(errors: except)
  end

  def get_misc_info
      #Make this a single request...
      if ["estados_licitacion", "organismos_publicos"].include?(params[:info])
        render json: Redis.current.hgetall(params[:info])
        return
      end

      raise ArgumentError, "Parametros invalidos"
      rescue ArgumentError => except
        render json: json_message_to_frontend(errors: except)
  end

  private

    def verify_correct_date_format(*dates)
        # date = unix epoch format
        dates.each do |date|
          if !is_integer?(date)
            raise ArgumentError, "Fecha en formato inválido, por favor intentar de nuevo."
          end

          transformed_date = transform_date_format(date)
          #transformed date = "YYYY-MM-DD")
          split_date = transformed_date.split("-")

          if Date.valid_date? *split_date.map(&:to_i)
            return transformed_date
          end

          raise ArgumentError, "Fecha en formato inválido, por favor intentar de nuevo."
        end

    end

    def verify_valid_offset_format(offset)
      offset_value = offset
      if offset_value.nil? || offset_value.empty?
        offset_value = 0
      end
     
      if !is_integer?(offset_value) 
        raise ArgumentError, "Offset inválido (Debe ser número entero)"
      end
      offset
    end



    def verify_valid_always_from?(*values)
      values.each do |value|
        if !is_boolean? value
          raise ArgumentError, "Valor 'Siempre desde/siempre hasta' inválido (debe ser booleano)"
        end
      end
      true
    end


    def valid_get_info_params?
      
      params.permit(
                    :codigoLicitacion, :estadoLicitacion, 
                    :organismoPublico, :palabrasClave, 
                    :rutProveedor,
                    :startDate, :alwaysFromToday,
                    :endDate, :alwaysToToday,
                    :offset
                    )

    end

    def valid_get_misc_info_params?
      params.require(:info)
    end

  

end