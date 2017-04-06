require 'test_helper'

class CacheLicitacionesDataJobTest < ActiveJob::TestCase

  def setup
    @job = CacheLicitacionesData
    @mock_organismos_publicos = [
   {"CodigoEmpresa": "1034640",
    "NombreEmpresa": " CORPORACION MUNICIPAL DE PEÑALOLEN PARA EL DESARROLLO SOCIAL "},
   {"CodigoEmpresa": "1224636",
    "NombreEmpresa": "Agencia Chilena de Eficiencia Energética"},
   {"CodigoEmpresa": "7086",
    "NombreEmpresa": "Agencia de Cooperación Internacional de Chile - AGCI"}
    ]

    @mock_organismos_publicos_response = {"Cantidad": 3,
                                          "FechaCreacion": "2017-03-13T14:56:05.947",
                                          "listaEmpresas": @mock_organismos_publicos
                                          }
    @mock_estados_licitacion = {
                                  Todos: "",
                                  Publicada: 5,
                                  Cerrada: 6,
                                  Desierta: 7,
                                  Adjudicada: 8,
                                  Revocada: 15,
                                  Suspendida: 19
                                }
  end


  test "Caches organismos publicos" do

    stub_request(:get, "http://api.mercadopublico.cl/servicios/v1/Publico/Empresas/BuscarComprador?ticket=#{ENV['CC_TOKEN']}")
      .to_return(body: @mock_organismos_publicos_response.to_json, status: 200)

    assert_equal Hash.new, Redis.current.hgetall("organismos_publicos")

    @job.cache_organismos_publicos

    expected_organismos_publicos_values = @mock_organismos_publicos
                                            .reduce({}) do |accum, elem|
                                           
                                              codigo_organismo_publico = elem[:CodigoEmpresa]
                                              nombre_organismo_publico = elem[:NombreEmpresa]

                                              accum[codigo_organismo_publico] = nombre_organismo_publico
                                              accum
                                            end

    assert_equal expected_organismos_publicos_values, Redis.current.hgetall("organismos_publicos")


  end

  test "Caches estados licitacion" do
    assert_equal Hash.new, Redis.current.hgetall("estados_licitacion")
    
    @job.cache_estados_licitacion

    expected_estados_licitacion_values = @mock_estados_licitacion
                                            .reduce({}) do |acc, elem|
                                              #Transform value number into string
                                              #curr[0] = key, curr[1] = value
                                              acc[elem[0]] = elem[1].to_s
                                              acc
                                            end
    assert_equal expected_estados_licitacion_values.as_json, Redis.current.hgetall("estados_licitacion")
  end




end
