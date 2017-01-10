class RequestsController < ApplicationController
  include RequestsHelper
  before_action :valid_get_info_params?, only: :get_info
  before_action :valid_entity_params?, only: :get_entity_data
  before_action :authenticate_request!, only: :show_hello


  def get_info
    render json: filter_results(valid_get_info_params?)
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
        begin
            Date.parse(date)
            date.split("-")
            if Date.valid_date? date[0].to_i, date[1].to_i, date[2].to_i
              return date
            else
              raise ArgumentError, {"mensaje": "Fecha en formato inválido, por favor intentar de nuevo. Formato requerido: DD-MM-AAAA"} 
            end
        rescue ArgumentError => e
          render json: e
        end
    end


    def valid_get_misc_info_params?(params)
      begin 
        if ["estados_licitacion", "organismos_publicos"].include?(params)
          return true
        else
          raise ArgumentError
        end
      end
      rescue ArgumentError
        render json: {"mensaje": "Parametros invalidos"}
    end


    def valid_get_info_params?
      
      params.permit(:codigoLicitacion, :estadoLicitacion, :organismoPublico, :palabrasClave, :rutProveedor, :selectedDate)

    end

end