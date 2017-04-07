require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  CODIGOS_EXTERNOS_SET = :codigos_externos
  include RequestsHelper
  include ApplicationHelper

  def setup
    # Will probably have to mock the redis values?
    @first_result = Result.first
    @user = User.first
    @headers = sign_in_example_user
    Result.set_all_unique_codigo_externo_to_redis
    @connection = ActiveRecord::Base.connection
  end

  test 'correctly returns chilecompra data from the database when requested' do
    licitacion_data_params = {
      startDate: 1000,
      alwaysFromToday: false,
      alwaysToToday: false,
      endDate: Time.zone.now.to_i * 1000,
      palabrasClave: '',
      offset: 0,
      order_by: {
        fields: [],
        order: 'descending'
      }
    }

    run_the_test = lambda do |licitacion_data_params|
      post '/licitacion_data', params: licitacion_data_params.to_json, headers: @headers

      parsed_response = JSON.parse(@response.body)

      # Assert that the amount of unique codigo_externos is equal to the amount sent in the response's
      # "count" key
      assert_equal Result.last_per_codigo_externo.count, parsed_response['count']

      offset = licitacion_data_params[:offset] - 1 < 0 ? 0 : licitacion_data_params[:offset]
      limit = assigns(:result_limit_amount)
      start_date = transform_date_format(licitacion_data_params[:startDate])
      finish_date = transform_date_format(licitacion_data_params[:endDate])

      expected_codigos_externos = ActiveRecord::Base.connection.execute(
        "
        SELECT value -> 'Listado' -> 0 ->> 'CodigoExterno' as codigo_externo
        FROM results
        WHERE id IN
        (SELECT id FROM (
            SELECT id, updated_at,
                dense_rank() OVER (
                    PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                    ORDER BY value ->> 'FechaCreacion' DESC
                    ) as by_fecha_creacion
            FROM results
            WHERE to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') >= '#{start_date}'::date
            AND to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') <= '#{finish_date}'::date
        ) as q
        WHERE by_fecha_creacion < 2)
        ORDER BY value -> 'Listado' -> '0' -> 'CodigoExterno' DESC
        OFFSET #{offset}
        LIMIT 200
        "
      ).map { |res| res['codigo_externo'] }

      expected_ids = ActiveRecord::Base.connection.execute("
                                                            SELECT id
                                                            FROM results
                                                            WHERE id IN
                                                            (SELECT id FROM (
                                                                SELECT id, updated_at,
                                                                    dense_rank() OVER (
                                                                        PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                                                                        ORDER BY value ->> 'FechaCreacion' DESC
                                                                        ) as by_fecha_creacion
                                                                FROM results
                                                                WHERE to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') >= '#{start_date}'
                                                                AND to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') <= '#{finish_date}'
                                                            ) as q
                                                            WHERE by_fecha_creacion < 2)
                                                            ORDER BY value -> 'Listado' -> '0' -> 'CodigoExterno' DESC
                                                            OFFSET #{offset}
                                                            LIMIT 200
                                                          ").map { |res| res['id'] }

      # The response's codigo_externos
      parsed_response_codigos_externos = parsed_response['values'].map { |resp| resp['value']['Listado'][0]['CodigoExterno'] }.sort { |a, z| a <=> z }
      # And its ids
      parsed_response_ids = parsed_response['values'].map { |resp| resp['id'] }.sort { |a, z| a <=> z }

      # does the @result_limit_amount work?
      assert_equal limit, parsed_response_ids.length
      # They should be equal
      assert_equal expected_ids - parsed_response_ids, []
      assert_equal expected_codigos_externos - parsed_response_codigos_externos, []
    end

    run_the_test.call(licitacion_data_params)
    licitacion_data_params[:offset] = 200
    run_the_test.call(licitacion_data_params)
  end

  test 'Correctly filters by dates' do
    # "FechaCreacion" is the date we downloaded the record from chilecompra

    # Start date - YYYY-MM-DD format date of the first record from seeds.rb
    # We multiply the Time.parse date by 1000 since javascript uses ruby_unix_timestamp * 1000
    # as its timestamps
    offset_amount = 0

    licitacion_data_params = {
      startDate: Time.parse('2017-01-05').to_i * 1000,
      alwaysFromToday: false,
      alwaysToToday: false,
      endDate: Time.parse('2017-01-06').to_i * 1000,
      palabrasClave: '',
      offset: 0,
      order_by: {
        fields: [],
        order: 'descending'
      }
    }
    post '/licitacion_data', params: licitacion_data_params.to_json, headers: @headers
    assert_response 200
    parsed_response = JSON.parse @response.body

    start_date = transform_date_format(licitacion_data_params[:startDate])
    finish_date = transform_date_format(licitacion_data_params[:endDate])

    expected_response = ActiveRecord::Base.connection.execute("
                                                       SELECT *
                                                       FROM results
                                                       WHERE id IN (
                                                          SELECT id FROM (
                                                              SELECT id, updated_at,
                                                                  dense_rank() OVER (
                                                                      PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                                                                      ORDER BY value ->> 'FechaCreacion' DESC
                                                                      ) as by_fecha_creacion
                                                              FROM results
                                                              WHERE to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') >= '#{start_date}'
                                                              AND to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') <= '#{finish_date}'
                                                          ) as q
                                                          WHERE by_fecha_creacion < 2
                                                       )
                                                       ORDER BY value -> 'Listado' -> '0' -> 'CodigoExterno' DESC
                                                       LIMIT 200
                                                       OFFSET #{offset_amount}
                                                      ")

    expected_result_ids = expected_response.map { |result| result['id'] }

    expected_result_values = expected_response.map { |result| result['value'] }

    parsed_response_ids = parsed_response['values'].map { |result| result['id'] }

    parsed_response_values = parsed_response['values'].map { |result| result['value'] }

    assert_equal expected_result_ids - parsed_response_ids, []
    assert_equal expected_result_values - expected_result_values, []
  end

  test 'Correctly filters by palabras clave' do
    licitacion_data_params = {
      startDate: 1,
      alwaysFromToday: false,
      alwaysToToday: false,
      endDate: Time.zone.now.to_i * 1000,
      palabrasClave: 'SERVICIO DE MOVILIZACION',
      offset: 0,
      order_by: {
        fields: [],
        order: 'descending'
      }
    }

    post '/licitacion_data', params: licitacion_data_params.to_json, headers: @headers

    assert_response 200
    parsed_response = JSON.parse(@response.body)

    expected_response = @connection.execute('
                                             SELECT *
                                             FROM "results"
                                             WHERE "value"::json#>>\'{Listado,0,Nombre}\' LIKE ' + "\'%SERVICIO%\' " \
                                             'AND "value"::json#>>\'{Listado,0,Nombre}\' LIKE ' + "\'%DE%\' " \
                                             'AND "value"::json#>>\'{Listado,0,Nombre}\' LIKE ' + "\'%MOVILIZACION%\' " \
                                             '
                                             OR
                                              "value"::json#>>\'{Listado,0,Descripcion}\' LIKE ' + "\'%SERVICIO%\' " \
                                             'AND "value"::json#>>\'{Listado,0,Descripcion}\' LIKE ' + "\'%DE%\' " \
                                             'AND "value"::json#>>\'{Listado,0,Descripcion}\' LIKE ' + "\'%MOVILIZACION%\' ")
    expected_result_ids = expected_response.map { |result| result['id'] }
    expected_result_values = expected_response.map { |result| JSON.parse(result['value']) }

    actual_result_ids = parsed_response['values'].map { |result| result['id'] }
    actual_result_values = parsed_response['values'].map { |result| result['value'] }

    assert_equal expected_result_ids, actual_result_ids
    assert_equal expected_result_values, actual_result_values
  end

  test 'returns error when getting chilecompra data with unpermitted params' do
    licitacion_data_params = {
      startDate: 1 * 1000,
      alwaysFromToday: false,
      alwaysToToday: false,
      endDate: Time.zone.now.to_i * 1000,
      offset: 0,
      order_by: { fields: [] },
      madeUpParam: 'Math.sqrt(-1)'
    }

    post '/licitacion_data', params: licitacion_data_params.to_json, headers: @headers

    assert_response 422
    expected_response = { message: { errors: 'Parámetros inválidos' } }.to_json
    assert_equal @response.body, expected_response
  end

  test 'correctly returns estados_licitacion when requested' do
    get '/chilecompra_misc_data?info=estados_licitacion', headers: @headers

    assert_equal Redis.current.hgetall('estados_licitacion'), JSON.parse(@response.body)
  end

  test 'correctly returns organismos_publicos when requested' do
    get '/chilecompra_misc_data?info=organismos_publicos', headers: @headers
    assert_equal Redis.current.hgetall('organismos_publicos'), JSON.parse(@response.body)
  end

  test 'Returns an error when passing random parameters to chilecompra_misc_data' do
    headers = sign_in_example_user
    get '/chilecompra_misc_data?random_param=random_value', headers: @headers
    assert_response 422
    expected_response = { message: { errors: 'Parámetros inválidos' } }.to_json
    assert_equal @response.body, expected_response
  end

  test 'Returns an error when passing some other value in the :info param' do
    get '/chilecompra_misc_data?info=this_is_not_valid', headers: @headers

    assert_response 422
    expected_response = { message: { errors: 'Parámetros inválidos' } }.to_json
    assert_equal @response.body, expected_response
  end
 end
