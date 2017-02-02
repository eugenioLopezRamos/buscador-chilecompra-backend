class RequestsController < ApplicationController
  include RequestsHelper
  before_action :valid_get_info_params?, only: :get_info
  before_action :valid_entity_params?, only: :get_entity_data
  before_action :authenticate_request!, only: :show_hello
  #before_action :verify_correct_date, only :get_info


  def get_info
    verify_correct_date(valid_get_info_params?[:selectedDate])
    verify_valid_offset(valid_get_info_params?[:offset])
   # binding.pry
    filter_results(valid_get_info_params?)

    rescue ArgumentError => except
          render json: json_message_to_frontend(errors: except)
  end

  def get_misc_info
    #This will be replaced too.
    mod = ApplicationController::ApplicationHelper
    if valid_get_misc_info_params?(params["info"]) && mod.respond_to?(params["info"])
       requested_info = mod.send("#{params['info']}")
   
      render json: requested_info
    end
  end

  private

    def verify_correct_date(date)
        # date = unix epoch format
        if !is_number?(date)
         raise ArgumentError, "Fecha en formato inválido, por favor intentar de nuevo."
        end

        transformed_date = transform_date_format(date.to_i)
        #transformed date = YYYY-MM-DD
        Date.parse(transformed_date)
        split_date = transformed_date.split("-")

        if Date.valid_date? split_date[0].to_i, split_date[1].to_i, split_date[2].to_i
          return transformed_date
        end
        raise ArgumentError, "Fecha en formato inválido, por favor intentar de nuevo."

    end

    def verify_valid_offset(offset)
     
      if !offset.empty? && !is_number?(offset) 
        raise ArgumentError, "Offset inválido"
      end
      offset
    end

    def valid_get_misc_info_params?(params)

      if ["estados_licitacion", "organismos_publicos"].include?(params)
        return true
      end
      raise ArgumentError, "Parametros invalidos"
      rescue ArgumentError => except
        binding.pry
        render json: json_message_to_frontend(error: except)
    end


    def valid_get_info_params?
      
      params.permit(:codigoLicitacion, :estadoLicitacion, :organismoPublico, :palabrasClave, :rutProveedor, :selectedDate, :offset)

    end

end