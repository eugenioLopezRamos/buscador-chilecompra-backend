require 'test_helper'
#debugger
require "#{Rails.root}/test/jobs/get_single_licitacion_mock.rb"
  
class GetSingleLicitacionJobTest < ActiveJob::TestCase
  include GetSingleLicitacionMock

  def setup
    @uri = "http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?ticket=#{ENV['CC_TOKEN']}"
    @codigos = ["1004-12-L117", "1002-7-LE17"]
    @response1 = GetSingleLicitacionMock.response1
    @response2 = GetSingleLicitacionMock.response2
    @job = GetSingleLicitacion
  end


  test "Gets a single licitacion from the chilecompra server" do

    #stub response 1
    stub_request(:get, @uri << "&Codigo=#{@codigos[0]}")
      .to_return(body: @response1.to_json, status: 200)

    #stub response 2
    stub_request(:get, @uri << "&Codigo=#{@codigos[1]}")
      .to_return(body: @response2.to_json, status: 200)

    @job.perform(@codigos[0], @uri)
    assert_queued(SaveSingleLicitacionToDB, [@response1])

    @job.perform(@codigos[1], @uri)
    assert_queued(SaveSingleLicitacionToDB, [@response2])


  end


end
