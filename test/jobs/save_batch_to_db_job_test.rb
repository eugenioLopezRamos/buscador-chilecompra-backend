require 'test_helper'
require "#{Rails.root}/test/mocks/get_licitaciones_mock.rb"

class SaveBatchToDbJobTest < ActiveJob::TestCase
  include GetLicitacionesMock

  def setup
    @batch = GetLicitacionesMock.mock_chilecompra_response
    @job = SaveBatchToDB
  end

  test "Saves batch to db" do

    assert_difference 'Batch.count', 1 do
      @job.perform(@batch)
    end
    
    assert_equal @batch.as_json, Batch.last.value.as_json
  end


end
