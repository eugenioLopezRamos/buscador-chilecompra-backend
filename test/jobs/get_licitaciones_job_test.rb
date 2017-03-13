require 'test_helper'
require "#{Rails.root}/test/mocks/get_licitaciones_mock.rb"

class GetLicitacionesJobTest < ActiveJob::TestCase
  include GetLicitacionesMock

  def setup
    @job = GetLicitaciones
    @mock_chilecompra_response = GetLicitacionesMock.mock_chilecompra_response
  end


  test "Gets licitaciones from chilecompra" do
    licitaciones_del_dia_uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?ticket=#{ENV['CC_TOKEN']}"

    stub_request(:get, licitaciones_del_dia_uri)
      .to_return(body: @mock_chilecompra_response.to_json, status: 200)

    @job.perform

    assert_queued(SaveBatchToDB, [@mock_chilecompra_response])
    
    assert_queued(GetSingleLicitacion, ["1002-7-LE17", licitaciones_del_dia_uri])
    assert_queued(GetSingleLicitacion, ["1004-12-L117", licitaciones_del_dia_uri])

  end

end
