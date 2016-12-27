class GetLicitaciones
    @queue = :licitaciones
    #Currently (12/22/2016) this is a duplicate of requests_controller. Requests controller will be replaced with calls to postgres later.
    @API_key = ENV['CC_TOKEN']
    @API_key_uri = "ticket=" << @API_key
    @API_licitaciones_uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?"
    @API_buscar_proveedores_uri = "http://api.mercadopublico.cl/servicios/v1/publico/empresas/BuscarProveedor?rutempresaproveedor="
    @API_buscar_comprador_uri = "http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?rutempresaproveedor="

    def self.perform

        @licitaciones_del_dia_uri = @API_licitaciones_uri + @API_key_uri

        File.open("#{Rails.root}/log/get_licitaciones.log", "a+"){|f| f << "Obteniendo batch a las #{Time.now()} \n" }
        
        @response = Net::HTTP.get(URI(@licitaciones_del_dia_uri))

        #save the batch to DB
        Resque.enqueue(SaveBatchToDB, JSON.parse(@response))

        File.open("#{Rails.root}/log/get_licitaciones.log", "a+"){|f| f << "Batch encolado a las #{Time.now()} \n" }

        @listado = JSON.parse(@response)["Listado"]
        File.open("#{Rails.root}/log/get_licitaciones.log", "a+"){|f| f << " JSON a las #{Time.now()} \n" }

        @listado.each do |lic|
            codigo_externo = lic["CodigoExterno"]
            File.open("#{Rails.root}/log/get_single_licitacion.log", "a+"){|f| f << "Encolando licitacion #{codigo_externo} a las #{Time.now()} \n" }
            Resque.enqueue(GetSingleLicitacion, codigo_externo, @licitaciones_del_dia_uri)
        end

    end
end