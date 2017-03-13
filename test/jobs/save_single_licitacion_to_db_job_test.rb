require 'test_helper'
require "#{Rails.root}/test/mocks/get_single_licitacion_mock.rb"

class SaveSingleLicitacionToDbJobTest < ActiveJob::TestCase
  include GetSingleLicitacionMock

  def setup
    #transforms keys from symbol to string without using reduce or similar which is
    #more verbose-y
    @licitacion = GetSingleLicitacionMock.response1.to_json
    @codigo_externo_lic = JSON.parse(@licitacion)["Listado"][0]["CodigoExterno"]
    @job = SaveSingleLicitacionToDB
  end

  test "Saves a single licitacion to the DB" do

    assert_difference 'Result.count', 1 do
      @job.perform(JSON.parse(@licitacion))
    end
    assert_equal JSON.parse(@licitacion).as_json, Result.last.value

    #Modifies the licitacion slightly, so it creates a notif

    original_licitacion = GetSingleLicitacionMock.response1.deep_dup
    original_licitacion[:Listado][0][:Nombre] = "mockname"
 
    assert_difference 'Result.count', 1 do
      @job.perform(original_licitacion.as_json)
    end

    assert_equal original_licitacion.as_json, Result.last.value
    assert_queued(AddLicitacionChangeToUserNotifications, [@codigo_externo_lic])

  end






end
