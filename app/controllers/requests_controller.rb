class RequestsController < ApplicationController

  before_action :valid_get_info_params?, only: :get_chilecompra_data
  before_action :valid_entity_params?, only: :get_entity_data
  before_action :authenticate_request!, only: :show_hello

  def initialize
    @API_key = ENV['CC_TOKEN']
    @API_key_uri = "ticket=" << @API_key
    @API_licitaciones_uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?"
    @API_buscar_proveedores_uri = "http://api.mercadopublico.cl/servicios/v1/publico/empresas/BuscarProveedor?rutempresaproveedor="
    @API_buscar_comprador_uri = "http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?rutempresaproveedor="
  end

  def testtwo
    #this is an example to test when the API is down/slow/etc
    @response = {"Cantidad":31,"FechaCreacion":"2016-11-14T12:42:09.707","Version":"v1","Listado":[{"CodigoExterno":"2105-32-L114","Nombre":"FARMACOS BRONCODILATADOR/CORTICOTERAPIA INHALATORIA","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-48-L114","Nombre":"FARMACOS CONTROLADOS ","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2471-363-L113","Nombre":"UTILES ESCOLARES, ESC. REP. DE MEXICO; SEP","CodigoEstado":8,"FechaCierre":"2014-01-08T19:26:00"},{"CodigoExterno":"2471-364-L113","Nombre":"MAT. MANUALIDADES-ESC.ARTURO MUTIZABAL-SEP","CodigoEstado":8,"FechaCierre":"2014-01-06T15:34:00"},{"CodigoExterno":"4012-1-L114","Nombre":"Compra de estuches de PVC para documentos.","CodigoEstado":7,"FechaCierre":"2014-01-10T19:30:00"},{"CodigoExterno":"1509-5-L114","Nombre":"Insumos Medicos y Medicamentos ","CodigoEstado":8,"FechaCierre":"2014-01-27T15:54:00"},{"CodigoExterno":"2105-38-LE14","Nombre":"ESOMEPRAZOL INYECTABLE","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-41-L114","Nombre":"FARMACOS ANTIBIOTICOS OFTALMICOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-49-L114","Nombre":"FARMACOS DIABETES (METFORMINA)","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2471-13-L114","Nombre":"Compra Leccionarios Unidades Educactivas DAEM 2014","CodigoEstado":8,"FechaCierre":"2014-01-27T15:00:00"},{"CodigoExterno":"2756-261-LP13","Nombre":"Propuesta pública Asesoría UTP DAEM","CodigoEstado":7,"FechaCierre":"2013-08-27T14:00:00"},{"CodigoExterno":"2105-1013-L113","Nombre":"INSUMOS MEDICOS ","CodigoEstado":8,"FechaCierre":"2013-10-29T12:00:00"},{"CodigoExterno":"2105-33-L114","Nombre":"FLUTICASONA INHALADOR","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-35-L114","Nombre":"CREMAS/SUPOSITORIOS/JARABES/GOTAS ORALES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-36-L114","Nombre":"FLUTICASONA INHALADOR","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-40-L114","Nombre":"FARMACOS ANTIBIOTICOS INYECTABLES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-42-L114","Nombre":"FARMACOS ANTICOAGULANTES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-43-LE14","Nombre":"FARMACOS ANTIGLAUCOMATOSOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-44-LE14","Nombre":"FARMACOS COMPRIMIDOS VARIOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-4-L114","Nombre":"ELECTRODOS NEONATALES ","CodigoEstado":8,"FechaCierre":"2014-01-10T12:00:00"},{"CodigoExterno":"2471-287-L113","Nombre":"CURSO TECNOLOGICO APROPIACION DE TIC-P. HARRIS-SEP","CodigoEstado":7,"FechaCierre":"2013-10-04T18:00:00"},{"CodigoExterno":"2471-365-LE13","Nombre":"UNIFORMES INSTITUCIONALES; ESC. LOS HEROES; SEP","CodigoEstado":8,"FechaCierre":"2014-01-10T15:35:00"},{"CodigoExterno":"1509-6-L114","Nombre":"Medicamentos e Insumos No Despacho Cenabast","CodigoEstado":8,"FechaCierre":"2014-01-27T15:25:00"},{"CodigoExterno":"2105-1128-L113","Nombre":"INSUMOS MEDICOS ","CodigoEstado":8,"FechaCierre":"2013-12-10T12:00:00"},{"CodigoExterno":"2105-34-L114","Nombre":"CICLOSPORINAS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-37-L114","Nombre":"ERITROPOYETINA ","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-39-LE14","Nombre":"FARMACOS ANTIRREUMATICOS ANTIARTRITICOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-6-L114","Nombre":"ELEMENTOS DE PROTECCION PERSONAL  ","CodigoEstado":8,"FechaCierre":"2014-01-13T15:00:00"},{"CodigoExterno":"2471-317-L113","Nombre":"ESTUFAS Y KIT DE CAÑONES -ANTONIO MACHADO-SEP","CodigoEstado":7,"FechaCierre":"2013-11-05T16:00:00"},{"CodigoExterno":"2471-346-L113","Nombre":"MAT.LABORATORIO CIENCIA-LICEO NARCISO TONDREAU-SEP","CodigoEstado":8,"FechaCierre":"2013-12-27T23:33:00"},{"CodigoExterno":"608-128-L114","Nombre":"ern ESTERILIZACIÓN - MEMO Nº 4109  Sacos Papel Grado Médico","CodigoEstado":8,"FechaCierre":"2014-01-27T15:01:00"}]}
    render json: @response
  end

  def get_misc_info
  
    mod = ApplicationController::ApplicationHelper
    if valid_get_misc_info_params?(params["info"]) && mod.respond_to?(params["info"])
       requested_info = mod.send("#{params['info']}")
   
      render json: requested_info
    end
  end
  
  def transform_date_format
    ->(date){
      Time.at(date.to_i/1000).strftime("%d%m%Y") #Need to divide the MomentJS date  by 1000 to get the correct one.
    }
  end

  def get_chilecompra_data

    @query_string = build_query_string(params)
    @outward_api_call = @API_licitaciones_uri

    @query_string.each do |q|
      @outward_api_call << q << "&"
    end

    @outward_api_call << @API_key_uri
    puts "VALOR DEL URI #{@outward_api_call}"

    @response = Net::HTTP.get(URI(@outward_api_call))

    @palabras_clave = params["palabrasClave"].to_s

    if !@palabras_clave.blank?
      @response = filter_palabras_clave(@response, @palabras_clave, "list")
    end
      # returns result
    render json: @response
  end

  def return_example_user
    #just an example user
    render json: {"name": "Examply McXample", "age": "28", "motto": "abcdefg", "finally": "the end"}

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
          raise ArgumentError("Parametros invalidos")
        end
      end
      rescue ArgumentError
        render json: {"mensaje": "Parametros invalidos"}
    end

    def valid_get_info_params?
      
      params.permit(:codigoLicitacion, :estadoLicitacion, :organismoPublico, :palabrasClave, :rutProveedor, :selectedDate)

    end

    def build_query_string(params)

      @query_parameters = Array.new

      ################### CODIGO LICITACION
      @codigo_licitacion = params["codigoLicitacion"].to_s
      @query_parameters.push("codigo=" << @codigo_licitacion) unless @codigo_licitacion.blank?

      ################ ESTADO LICITACION
      @estado_licitacion = params["estadoLicitacion"].to_s
      if @estado_licitacion === "Todos"
        @estado_licitacion = ""
      end
      @query_parameters.push("estado=" << @estado_licitacion) unless @estado_licitacion.blank?

      ############# DATE
      @selected_date = transform_date_format.(params["selectedDate"])                                  
      @query_parameters.push("fecha=" << @selected_date) unless @selected_date.blank?

      ################ ORGANISMO PUBLICO
      @organismo_publico = params["organismoPublico"].to_s === "*" ? "" : params["organismoPublico"]
      @query_parameters.push("codigoOrganismo=" << @organismo_publico) unless @organismo_publico.blank?

      ############# RUT PROVEEDOR
      @rut_proveedor = params["rutProveedor"].to_s
      if !@rut_proveedor.blank?
        @info_proveedor = get_codigo_proveedor(@rut_proveedor, @API_buscar_proveedores_uri)

        @codigo_proveedor = JSON.parse(@info_proveedor)["CodigoEmpresa"]
        @nombre_proveedor = JSON.parse(@info_proveedor)["NombreEmpresa"]
      end
      @query_parameters.push("codigoProvedor=" << @codigo_proveedor) unless @codigo_proveedor.blank?

      @query_parameters
    end

    def get_codigo_proveedor
      return Proc.new { 
        |proveedor, uri| 
        to_get = uri << proveedor << @API_key_uri
        to_get = URI(to_get)
        @response = Net::HTTP.get(to_get)
        @return_value = JSON.parse(@response)
        @return_value = @return_value["listaEmpresas"][0] # "listaEmpresas is a 1 length array, so [0] returns => {"CodigoEmpresa": "111", "NombreEmpresa": "abcd S.A"}
        return @return_value
      } 
    end

    def filter_palabras_clave(results, filter, type="list")
      #type can be list (all licitaciones) or single (a single licitacion, which has much more detail)
      case type
        when "list"
      orig_results = results
      new_results = JSON.parse(results)
      filter_string = Regexp.new(filter.downcase)
      # Here I could probably split the different words in regex groups and check against that. It might be a little slow though?

      filtered_listado = JSON.parse(orig_results)["Listado"].select { 
        |x| 
        
        if x["Nombre"].downcase.match(filter_string)
          x
        end
      }

      new_results["Cantidad"] = filtered_listado.length
      new_results["Listado"] = filtered_listado

      when "single"
          #### TODO
      end

      return new_results
    end



end
 