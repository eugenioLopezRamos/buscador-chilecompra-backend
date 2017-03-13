require 'test_helper'

class GetLicitacionesJobTest < ActiveJob::TestCase

  def setup
    @job = GetLicitaciones
    @mock_lista_licitaciones = [
      {
        CodigoEstado:6,
        CodigoExterno: "1002-7-LE17",
        FechaCierre: "2017-03-13T15:29:00",
        Nombre: "SERVICIO DE ASEO OFICINAS DIRECCION DE VIALIDAD"},
      {
        CodigoEstado:5,
        CodigoExterno:"1004-12-L117",
        FechaCierre:"2017-03-20T15:40:00",
        Nombre:"SUMINISTRO DE LEÑA PARA VIALIDAD CHILE CHICO"
      }

    ]
    @mock_chilecompra_response = {
      "Cantidad": 2,
      "FechaCreacion": "2017-03-13T15:30:24.913",
      "Version": "v1",
      "Listado": @mock_lista_licitaciones
    }


  end


  test "Gets licitaciones from chilecompra" do
    licitaciones_del_dia_uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?ticket=#{ENV['CC_TOKEN']}"

    stub_request(:get, licitaciones_del_dia_uri)
      .to_return(body: @mock_chilecompra_response.to_json, status: 200)
    #debugger
    @job.perform

    assert_queued(SaveBatchToDB, [@mock_chilecompra_response])
    
    assert_queued(GetSingleLicitacion, ["1002-7-LE17", licitaciones_del_dia_uri])
    assert_queued(GetSingleLicitacion, ["1004-12-L117", licitaciones_del_dia_uri])

  end

end
