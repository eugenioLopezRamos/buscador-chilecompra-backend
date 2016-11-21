class RequestsController < ApplicationController

  before_action :valid_get_info_params?, only: :get_chilecompra_data
  before_action :valid_entity_params?, only: :get_entity_data
  before_filter :authenticate_request!, only: :show_hello

  def search(params)

      @API_key = ENV['CC_TOKEN']
      @date = verify_correct_date(params[:date])

      #consulta de ejemplo, para pruebas.
      @URI = URI("http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?fecha=#{@date}&ticket=" << @API_key)
      Net::HTTP.get @URI

      #Posibles campos (partes a incluir en la query a realizar a la API)

      # FECHA => fecha=05051988 (fecha en particular) 

      # CODIGO LICITACION => codigo=1509-5-L114

      # TODOS LOS ESTADOS DEL DIA ACTUAL => licitaciones.json?ticket=xxxx (por defecto/ params vacios)

      # ESTADO => estado={estado} (sacar de ApplicationHelper)

      # CODIGO ORGANISMO PUBLICO => CodigoOrganismo=XXXXX (buscar codigos de org publicos para consultar y guardar) => BuscarComprador?ticket=@API_key
      # CODIGO PROVEEDOR => CodigoProveedor=XXXXX (existe doc de esto?) => rutempresaproveedor=(RUT CON PUNTOS Y GUION)





# Códigos de Organismos Públicos y Proveedores

#Para obtener el código de un Proveedor debe consumir el siguiente método indicando el rut de la empresa a buscar (debe incluir puntos, guion y digito verificador):
#http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarProveedor?rutempresaproveedor=70.017.820-k&ticket=F8537A18-6766-4DEF-9E59-426B4FEE2844

#Donde:

 #   Código Empresa: Código de la empresa Proveedor. Ejemplo de {CodigoEmpresa} = 17793
  #  Nombre Empresa: Nombre de la empresa Proveedor. Ejemplo de {NombreEmpresa} = "Cámara de Comercio de Santiago A.G. (CCS)".


#Para obtener el código de un Organismo Público debe consumir el siguiente método, el cual devuelve un listado de todos los Organismos Públicos de la plataforma Mercado Publico:
#http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?ticket=F8537A18-6766-4DEF-9E59-426B4FEE2844

#Donde:

 #   Código Empresa: Código del organismo público. Ejemplo de {CodigoEmpresa} = 6945
  #  Nombre Empresa: Nombre del organismo público. Ejemplo de {NombreEmpresa} = "Dirección de Compras y Contratación Pública".








      # Para sacar los datos de cada licitaciones se usa la key "Listado" la cual es un array de hashes (o de objetos JSON, como quieras verlo). Ejemplo de datos sacados el 14/11/16 12:40 PM:

     # {
     #  "Cantidad":31,"
     #  FechaCreacion":"2016-11-14T12:42:09.707",
     # "Version":"v1",
     # "Listado":[
     #  {"CodigoExterno":"2105-32-L114",
     #   "Nombre":"FARMACOS BRONCODILATADOR/CORTICOTERAPIA INHALATORIA",
     #   "CodigoEstado":8,
     #   "FechaCierre":"2014-01-28T09:00:00"
     #   },
     #  {"CodigoExterno":"2105-48-L114","Nombre":"FARMACOS CONTROLADOS ","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2471-363-L113","Nombre":"UTILES ESCOLARES, ESC. REP. DE MEXICO; SEP","CodigoEstado":8,"FechaCierre":"2014-01-08T19:26:00"},{"CodigoExterno":"2471-364-L113","Nombre":"MAT. MANUALIDADES-ESC.ARTURO MUTIZABAL-SEP","CodigoEstado":8,"FechaCierre":"2014-01-06T15:34:00"},{"CodigoExterno":"4012-1-L114","Nombre":"Compra de estuches de PVC para documentos.","CodigoEstado":7,"FechaCierre":"2014-01-10T19:30:00"},{"CodigoExterno":"1509-5-L114","Nombre":"Insumos Medicos y Medicamentos ","CodigoEstado":8,"FechaCierre":"2014-01-27T15:54:00"},{"CodigoExterno":"2105-38-LE14","Nombre":"ESOMEPRAZOL INYECTABLE","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-41-L114","Nombre":"FARMACOS ANTIBIOTICOS OFTALMICOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-49-L114","Nombre":"FARMACOS DIABETES (METFORMINA)","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2471-13-L114","Nombre":"Compra Leccionarios Unidades Educactivas DAEM 2014","CodigoEstado":8,"FechaCierre":"2014-01-27T15:00:00"},{"CodigoExterno":"2756-261-LP13","Nombre":"Propuesta pública Asesoría UTP DAEM","CodigoEstado":7,"FechaCierre":"2013-08-27T14:00:00"},{"CodigoExterno":"2105-1013-L113","Nombre":"INSUMOS MEDICOS ","CodigoEstado":8,"FechaCierre":"2013-10-29T12:00:00"},{"CodigoExterno":"2105-33-L114","Nombre":"FLUTICASONA INHALADOR","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-35-L114","Nombre":"CREMAS/SUPOSITORIOS/JARABES/GOTAS ORALES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-36-L114","Nombre":"FLUTICASONA INHALADOR","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-40-L114","Nombre":"FARMACOS ANTIBIOTICOS INYECTABLES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-42-L114","Nombre":"FARMACOS ANTICOAGULANTES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-43-LE14","Nombre":"FARMACOS ANTIGLAUCOMATOSOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-44-LE14","Nombre":"FARMACOS COMPRIMIDOS VARIOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-4-L114","Nombre":"ELECTRODOS NEONATALES ","CodigoEstado":8,"FechaCierre":"2014-01-10T12:00:00"},{"CodigoExterno":"2471-287-L113","Nombre":"CURSO TECNOLOGICO APROPIACION DE TIC-P. HARRIS-SEP","CodigoEstado":7,"FechaCierre":"2013-10-04T18:00:00"},{"CodigoExterno":"2471-365-LE13","Nombre":"UNIFORMES INSTITUCIONALES; ESC. LOS HEROES; SEP","CodigoEstado":8,"FechaCierre":"2014-01-10T15:35:00"},{"CodigoExterno":"1509-6-L114","Nombre":"Medicamentos e Insumos No Despacho Cenabast","CodigoEstado":8,"FechaCierre":"2014-01-27T15:25:00"},{"CodigoExterno":"2105-1128-L113","Nombre":"INSUMOS MEDICOS ","CodigoEstado":8,"FechaCierre":"2013-12-10T12:00:00"},{"CodigoExterno":"2105-34-L114","Nombre":"CICLOSPORINAS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-37-L114","Nombre":"ERITROPOYETINA ","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-39-LE14","Nombre":"FARMACOS ANTIRREUMATICOS ANTIARTRITICOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-6-L114","Nombre":"ELEMENTOS DE PROTECCION PERSONAL  ","CodigoEstado":8,"FechaCierre":"2014-01-13T15:00:00"},{"CodigoExterno":"2471-317-L113","Nombre":"ESTUFAS Y KIT DE CAÑONES -ANTONIO MACHADO-SEP","CodigoEstado":7,"FechaCierre":"2013-11-05T16:00:00"},{"CodigoExterno":"2471-346-L113","Nombre":"MAT.LABORATORIO CIENCIA-LICEO NARCISO TONDREAU-SEP","CodigoEstado":8,"FechaCierre":"2013-12-27T23:33:00"},{"CodigoExterno":"608-128-L114","Nombre":"ern ESTERILIZACIÓN - MEMO Nº 4109  Sacos Papel Grado Médico","CodigoEstado":8,"FechaCierre":"2014-01-27T15:01:00"}]}


  end

  def test
      render json: {"test": "successful!"}
  end


  def testtwo

    @API_key = ENV['CC_TOKEN']
    @URI = URI("http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?fecha=02022014&ticket=" << @API_key)
    #@response = Net::HTTP.get @URI

    #this is an example to test when the API is down/slow/etc
    @response = {"Cantidad":31,"FechaCreacion":"2016-11-14T12:42:09.707","Version":"v1","Listado":[{"CodigoExterno":"2105-32-L114","Nombre":"FARMACOS BRONCODILATADOR/CORTICOTERAPIA INHALATORIA","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-48-L114","Nombre":"FARMACOS CONTROLADOS ","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2471-363-L113","Nombre":"UTILES ESCOLARES, ESC. REP. DE MEXICO; SEP","CodigoEstado":8,"FechaCierre":"2014-01-08T19:26:00"},{"CodigoExterno":"2471-364-L113","Nombre":"MAT. MANUALIDADES-ESC.ARTURO MUTIZABAL-SEP","CodigoEstado":8,"FechaCierre":"2014-01-06T15:34:00"},{"CodigoExterno":"4012-1-L114","Nombre":"Compra de estuches de PVC para documentos.","CodigoEstado":7,"FechaCierre":"2014-01-10T19:30:00"},{"CodigoExterno":"1509-5-L114","Nombre":"Insumos Medicos y Medicamentos ","CodigoEstado":8,"FechaCierre":"2014-01-27T15:54:00"},{"CodigoExterno":"2105-38-LE14","Nombre":"ESOMEPRAZOL INYECTABLE","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-41-L114","Nombre":"FARMACOS ANTIBIOTICOS OFTALMICOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-49-L114","Nombre":"FARMACOS DIABETES (METFORMINA)","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2471-13-L114","Nombre":"Compra Leccionarios Unidades Educactivas DAEM 2014","CodigoEstado":8,"FechaCierre":"2014-01-27T15:00:00"},{"CodigoExterno":"2756-261-LP13","Nombre":"Propuesta pública Asesoría UTP DAEM","CodigoEstado":7,"FechaCierre":"2013-08-27T14:00:00"},{"CodigoExterno":"2105-1013-L113","Nombre":"INSUMOS MEDICOS ","CodigoEstado":8,"FechaCierre":"2013-10-29T12:00:00"},{"CodigoExterno":"2105-33-L114","Nombre":"FLUTICASONA INHALADOR","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-35-L114","Nombre":"CREMAS/SUPOSITORIOS/JARABES/GOTAS ORALES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-36-L114","Nombre":"FLUTICASONA INHALADOR","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-40-L114","Nombre":"FARMACOS ANTIBIOTICOS INYECTABLES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-42-L114","Nombre":"FARMACOS ANTICOAGULANTES","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-43-LE14","Nombre":"FARMACOS ANTIGLAUCOMATOSOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-44-LE14","Nombre":"FARMACOS COMPRIMIDOS VARIOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-4-L114","Nombre":"ELECTRODOS NEONATALES ","CodigoEstado":8,"FechaCierre":"2014-01-10T12:00:00"},{"CodigoExterno":"2471-287-L113","Nombre":"CURSO TECNOLOGICO APROPIACION DE TIC-P. HARRIS-SEP","CodigoEstado":7,"FechaCierre":"2013-10-04T18:00:00"},{"CodigoExterno":"2471-365-LE13","Nombre":"UNIFORMES INSTITUCIONALES; ESC. LOS HEROES; SEP","CodigoEstado":8,"FechaCierre":"2014-01-10T15:35:00"},{"CodigoExterno":"1509-6-L114","Nombre":"Medicamentos e Insumos No Despacho Cenabast","CodigoEstado":8,"FechaCierre":"2014-01-27T15:25:00"},{"CodigoExterno":"2105-1128-L113","Nombre":"INSUMOS MEDICOS ","CodigoEstado":8,"FechaCierre":"2013-12-10T12:00:00"},{"CodigoExterno":"2105-34-L114","Nombre":"CICLOSPORINAS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-37-L114","Nombre":"ERITROPOYETINA ","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-39-LE14","Nombre":"FARMACOS ANTIRREUMATICOS ANTIARTRITICOS","CodigoEstado":8,"FechaCierre":"2014-01-28T09:00:00"},{"CodigoExterno":"2105-6-L114","Nombre":"ELEMENTOS DE PROTECCION PERSONAL  ","CodigoEstado":8,"FechaCierre":"2014-01-13T15:00:00"},{"CodigoExterno":"2471-317-L113","Nombre":"ESTUFAS Y KIT DE CAÑONES -ANTONIO MACHADO-SEP","CodigoEstado":7,"FechaCierre":"2013-11-05T16:00:00"},{"CodigoExterno":"2471-346-L113","Nombre":"MAT.LABORATORIO CIENCIA-LICEO NARCISO TONDREAU-SEP","CodigoEstado":8,"FechaCierre":"2013-12-27T23:33:00"},{"CodigoExterno":"608-128-L114","Nombre":"ern ESTERILIZACIÓN - MEMO Nº 4109  Sacos Papel Grado Médico","CodigoEstado":8,"FechaCierre":"2014-01-27T15:01:00"}]}

    render json: @response

  end

  def get_misc_info
  
    mod = ApplicationController::ApplicationHelper
    if valid_get_misc_info_params?(params["info"]) && mod.respond_to?(params["info"])
       requested_info = mod.send("#{params['info']}")
   
      render json: requested_info.to_json
    end
  end
  

  def get_codigo_proveedor
    return Proc.new { 
      |proveedor, uri| 
      to_get = uri << proveedor << @API_key_uri
      to_get = URI(to_get)
      @response = Net::HTTP.get(to_get)
      @return_value = JSON.parse(@response)
      @return_value = @return_value["listaEmpresas"][0] # "listaEmpresas is a 1 length array, so [0] returns => {"CodigoEmpresa": "111", "NombreEmpresa": "abcd"}
      return @return_value
    } 


  end

  def get_chilecompra_data

    @API_key = ENV['CC_TOKEN']
    @API_key_uri = "ticket=" << @API_key
    @API_licitaciones_uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?"
    @API_buscar_proveedores_uri = "http://api.mercadopublico.cl/servicios/v1/publico/empresas/BuscarProveedor?rutempresaproveedor="

    @data = params
    
    @query_parameters = Array.new

    @codigo_licitacion = params["codigoLicitacion"].to_s
    @query_parameters.push("codigo=" << @codigo_licitacion) unless @codigo_licitacion.blank?


    @estado_licitacion = params["estadoLicitacion"].to_s
    if @estado_licitacion === "Todos"
      @estado_licitacion = ""
    end

    @query_parameters.push("estado=" << @estado_licitacion) unless @estado_licitacion.blank?

    @selected_date = params["selectedDate"]
    @selected_date.gsub!("-", "")
    @query_parameters.push("fecha=" << @selected_date) unless @selected_date.blank?

    @organismo_publico = params["organismoPublico"].to_s
    #Here's a catch: the view currently presents name, but needs to send the code. Shouldn't be much work to fix this, since it already has number, only it does not display it.
    @query_parameters.push("codigoOrganismo=" << @organismo_publico) unless @organismo_publico.blank? # esta se usa aparte, al igual que los rutproveedor. O se puede usar despues de recibidos los datos

    @rut_proveedor = params["rutProveedor"].to_s
    if !@rut_proveedor.blank?
      @info_proveedor = get_codigo_proveedor(@rut_proveedor, @API_buscar_proveedores_uri)

      @codigo_proveedor = JSON.parse(@info_proveedor)["CodigoEmpresa"]
      @nombre_proveedor = JSON.parse(@info_proveedor)["NombreEmpresa"]
    end
    # Here's another catch! we need to get the code first.
    #####


    #####

    @query_parameters.push("codigoproveedor=" << @codigo_proveedor) unless @codigo_proveedor.blank? # esta se usa aparte, al igual que los rutproveedor. O se puede usar despues de recibidos los datos

    # Neither is this. They are used after fetching the results.

    @palabras_clave = params["palabrasClave"].to_s
    # This is not used for the query. No need to push it - It should be used after the results are received, to filter them.

    @outward_api_call = @API_licitaciones_uri

    @query_parameters.each do |q|

      @outward_api_call << q << "&"

    end

    @outward_api_call << @API_key_uri

    puts "VALOR DEL API TOKEN ES #{@API_key}"
    puts "VALOR DEL URI #{@outward_api_call}"


    @response = Net::HTTP.get(URI(@outward_api_call))


    #to be done => filter by palabras clave, etc


    
      # api call return json etc
      render json: @response
    

  end

  def get_entity_data 
    @API_proveedor_uri = URI("http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarProveedor?rutempresaproveedor=")
    @API_comprador_uri = URI("http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?rutempresaproveedor=")

  end


  def show_hello
    render json: {"message": "hey there"}
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




end
 