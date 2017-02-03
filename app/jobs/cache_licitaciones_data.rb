class CacheLicitacionesData
  require 'net/http'
  require 'json'
  require 'redis'

  @queue = :licitaciones

  def self.perform
    cache_organismos_publicos
    cache_estados_licitacion
  end


  def self.cache_organismos_publicos
    uri = URI("http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?ticket=#{ENV['CC_TOKEN']}")
    #this is an array of hashes
    parsed_json_response = JSON.send(:parse, Net::HTTP.get(uri))["listaEmpresas"]
    
    response_hash = Hash.new
    parsed_json_response.reduce(response_hash) do |accumulator, current|
      codigo_organismo_publico = current["CodigoEmpresa"]
      nombre_organismo_publico = current["NombreEmpresa"]

      accumulator[codigo_organismo_publico] = nombre_organismo_publico
      accumulator

    end
    
    Redis.current.hmset("organismos_publicos", *response_hash)

  end

  def self.cache_estados_licitacion
    estados_licitacion = {
                          Todos: "",
                          Publicada: 5,
                          Cerrada: 6,
                          Desierta: 7,
                          Adjudicada: 8,
                          Revocada: 15,
                          Suspendida: 19
                         }
    Redis.current.hmset("estados_licitacion", *estados_licitacion)


  end

end