require 'test_helper'

class ResultTest < ActiveSupport::TestCase

  CODIGOS_EXTERNOS_SET = Result::CODIGOS_EXTERNOS_SET

  def setup
    @connection = ActiveRecord::Base.connection

  end

  test "Should return all unique codigo_externos from db" do
    codigos = Result.get_all_unique_codigo_externo_from_db

    query_result = @connection.execute('SELECT DISTINCT "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' AS "codigo_externo" FROM "results"')
    
    assert_equal codigos.length, query_result.count

    codigos_from_query = []

    query_result.each do |tuple|
      tuple.each_pair do |key, value|
        codigos_from_query.push value
      end
    end

    assert_equal codigos - codigos_from_query, []
  end

  test "Should get all codigo externos from redis" do
    #Tests if the ones from redis are the same as the ones from the db
    codigos_from_db = Result.get_all_unique_codigo_externo_from_db
    codigos_from_redis = Result.get_all_unique_codigo_externo(force_db: false)

    assert_equal codigos_from_db - codigos_from_redis, []

  end

  test "Should set all unique codigos externos to redis" do
    #Clear the redis set
    Redis.current.DEL(CODIGOS_EXTERNOS_SET)
    #Should be empty =>
    assert_equal Redis.current.smembers(CODIGOS_EXTERNOS_SET), []

    Result.set_all_unique_codigo_externo_to_redis
    assert_equal Redis.current.smembers(CODIGOS_EXTERNOS_SET), Result.get_all_unique_codigo_externo

  end

  test "Should show a results history (all records with codigo_externo = result.codigo_externo)" do


  end

  test "Should show a results codigo_externo" do


  end

  test "Should get the last result.id with codigo_externo == result.codigo_externo" do

  end

  test "Should get all results with codigo_externo == result.codigo_externo" do 
  
  end

  test "Should get the latest entry per codigo externo" do

  end

end
