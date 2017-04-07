require 'test_helper'
# rubocop:disable Metrics/ClassLength
class ResultTest < ActiveSupport::TestCase
  include ApplicationHelper

  CODIGOS_EXTERNOS_SET = Result::CODIGOS_EXTERNOS_SET

  def setup
    @connection = ActiveRecord::Base.connection
  end

  test 'Should return all unique codigo_externos from db' do
    codigos = Result.all_unique_codigo_externo_from_db

    query_result = @connection.execute('SELECT DISTINCT "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' AS "codigo_externo" FROM "results"')

    assert_equal codigos.length, query_result.count

    codigos_from_query = []

    query_result.each do |tuple|
      tuple.each_pair do |_key, value|
        codigos_from_query.push value
      end
    end

    assert_equal codigos - codigos_from_query, []
  end

  test 'Should get all codigo externos from redis' do
    # Tests if the ones from redis are the same as the ones from the db
    codigos_from_db = Result.all_unique_codigo_externo_from_db
    codigos_from_redis = Result.get_all_unique_codigo_externo(force_db: false)

    assert_equal codigos_from_db - codigos_from_redis, []
  end

  test 'Should set all unique codigos externos to redis' do
    # Clear the redis set
    Redis.current.DEL(CODIGOS_EXTERNOS_SET)
    # Should be empty =>
    assert_equal Redis.current.smembers(CODIGOS_EXTERNOS_SET), []

    Result.set_all_unique_codigo_externo_to_redis

    # Redis.current... minus Result.get_all.. = [] => They're equal
    # Another option would be sorting them first
    assert_equal Redis.current.smembers(CODIGOS_EXTERNOS_SET) - Result.all_unique_codigo_externo_from_db, []
  end

  test 'Should show a results history (all records with codigo_externo = result.codigo_externo)' do
    unique_codigos_externos = Result.all_unique_codigo_externo_from_db
    # Select a codigo_externo to test
    codigo_externo = unique_codigos_externos[(unique_codigos_externos.length / 2).floor]

    # result history of result with codigo_externo
    test_result = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo_externo).last.history

    all_with_codigo_externo = @connection.execute('SELECT *
                                                   FROM "results"
                                                   WHERE "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' = \'' + codigo_externo + "\'" + '
                                                   ORDER BY "results"."created_at" DESC
                                                   ')
    # Transform PG object into array & json stringified ["value"] to hash
    all_with_codigo_externo = all_with_codigo_externo.map do |result|
      result['value'] = JSON.parse(result['value'])
      result
    end

    all_with_codigo_externo.each_with_index do |result, index|
      # testing value and id because funny stuff happens with created_at and updated_at
      # when using to_json/as_json (date format changes)
      # Where the solution is to patch ActiveSupport::TimeWithZone, which in this case
      # I find unnecessary since the date is parsed client side anyways
      assert_equal result['value'], test_result.as_json[index]['value']
      assert_equal result['id'], test_result.as_json[index]['id']
    end
  end

  test 'Should show a results codigo_externo' do
    test_result = Result.first
    assert_equal test_result.codigo_externo, test_result.value['Listado'][0]['CodigoExterno']
  end

  test 'Should get the last result entry with codigo_externo == result.codigo_externo' do
    test_result = Result.last_per_codigo_externo.as_json

    sql_result = @connection.execute(
      "SELECT * FROM (
        SELECT *,
        dense_rank() OVER (
            PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
            ORDER BY id DESC
            ) as by_id
          FROM results
      ) as q
      WHERE by_id < 2"
    )

    sql_result = sql_result.map do |result|
      result['value'] = JSON.parse(result['value'])
      result.delete('by_id')
      result
    end

    test_result = test_result.sort { |a, z| a['id'] <=> z['id'] }
    sql_result = sql_result.sort { |a, z| a['id'] <=> z['id'] }

    # These are to avoid the transformation inconsistencies on created_at/updated_at using .to_json
    test_result_values = test_result.map { |result| result['value'] }
    sql_result_values = sql_result.map { |result| result['value'] }

    test_result_ids = test_result.map { |result| result['id'] }
    sql_result_ids = sql_result.map { |result| result['id'] }

    assert_equal [], test_result_values - sql_result_values
    assert_equal [], test_result_ids - sql_result_ids
  end

  test 'Should get all results with codigo_externo == result.codigo_externo' do
    codigo_externo = Result.first.codigo_externo
    test_result = Result.all_with_codigo_externo codigo_externo

    sql_result = @connection.execute('
                                      SELECT *
                                      FROM "results"
                                      WHERE "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' = \'' + codigo_externo + "\'")

    sql_result = sql_result.map do |result|
      result['value'] = JSON.parse(result['value'])
      result
    end

    # These are to avoid the transformation inconsistencies on created_at/updated_at using .to_json
    test_result = test_result.sort { |a, z| a['id'] <=> z['id'] }
    sql_result = sql_result.sort { |a, z| a['id'] <=> z['id'] }

    test_result_values = test_result.map { |result| result['value'] }
    sql_result_values = sql_result.map { |result| result['value'] }

    test_result_ids = test_result.map { |result| result['id'] }
    sql_result_ids = sql_result.map { |result| result['id'] }

    assert_equal [], test_result_values - sql_result_values
    assert_equal [], test_result_ids - sql_result_ids
  end

  test 'Should get the latest result.ids per codigo externo between dates' do
    start_date = transform_date_format(1000)
    end_date = transform_date_format(Time.zone.now.to_i * 1000)

    test_result_ids = Result.latest_entry_per_codigo_externo(start_date, end_date)

    start = @connection.quote(transform_date_format(start_date))
    finish = @connection.quote(transform_date_format(end_date))

    sql_result = @connection.execute(
      "SELECT id FROM (
          SELECT id, updated_at,
              dense_rank() OVER (
                  PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                  ORDER BY updated_at DESC
                  ) as by_updated_at
          FROM results
          WHERE updated_at > #{start}
          AND updated_at <= #{finish}
      ) as q
      WHERE by_updated_at < 2"
    )

    sql_result_ids = []

    sql_result.each do |hash|
      hash.each_pair { |_key, value| sql_result_ids.push value }
    end

    assert_equal [], sql_result_ids - test_result_ids
  end
end
# rubocop:enable Metrics/ClassLength
