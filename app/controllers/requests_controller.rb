class RequestsController < ApplicationController
  include RequestsHelper
  before_action :valid_get_info_params?, only: :get_info
  before_action :valid_entity_params?, only: :get_entity_data
  before_action :authenticate_request!, only: :show_hello

  # def initialize
  #   @API_key = ENV['CC_TOKEN']
  #   @API_key_uri = "ticket=" << @API_key
  #   @API_licitaciones_uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?"
  #   @API_buscar_proveedores_uri = "http://api.mercadopublico.cl/servicios/v1/publico/empresas/BuscarProveedor?rutempresaproveedor="
  #   @API_buscar_comprador_uri = "http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?rutempresaproveedor="
  # end

  def get_misc_info
    #This will be replaced too.
    mod = ApplicationController::ApplicationHelper
    if valid_get_misc_info_params?(params["info"]) && mod.respond_to?(params["info"])
       requested_info = mod.send("#{params['info']}")
   
      render json: requested_info
    end
  end

  # def get_chilecompra_data

  #   #builds the query string => param1=val1&param2=val2
  #   @query_string = build_query_string(params)

  #   #returns the API URI => chilecompra.cl/licitaciones?param1=value1&param2=value2&ticket=1234567
  #   @outward_api_call = @API_licitaciones_uri << @query_string << "&" << @API_key_uri

  #   #calls the API, gets the response
  #   @response = Net::HTTP.get(URI(@outward_api_call))

  #   @palabras_clave = params["palabrasClave"].to_s

  #   #filters the results with .select if @palabras_clave is NOT blank.
  #   @response = filter_palabras_clave(@response, @palabras_clave, "list") unless @palabras_clave.blank?

  #   # returns the result
  #   render json: @response
  # end


  def get_info
    @results = filter_results(params).pluck("value")
    render json: @results
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
        rescue ArgumentError
          render json: {"mensaje": "Fecha en formato inválido, por favor intentar de nuevo. Formato requerido: DD-MM-AAAA"} 
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
                                     #     .where('CodigoLicitacion -> ?', params[:codigoLicitacion].to_s)
                                       #  .where('Items ->> Listado -> 0 ->> Adjudicacion -> RutProveedor -> ?', params[:rutProveedor].to_s) 
                                               # val.Fechas.FechaPublicacion = params[:selectedDate],
                                                # val.Comprador.CodigoOrganismo -> ,
                                                # val.CodigoLicitacion -> params[:codigoLicitacion].to_s,
                                                # val.Items.Listado[0].Adjudicacion.RutProveedor -> params[:rutProveedor].to_s,
                #  )