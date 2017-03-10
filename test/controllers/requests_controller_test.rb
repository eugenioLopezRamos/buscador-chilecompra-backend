require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
    CODIGOS_EXTERNOS_SET = :codigos_externos
    include RequestsHelper

  def setup

    #Will probably have to mock the redis values?
    @first_result = Result.first
    @user = User.first
    @headers = sign_in_example_user
  #  Rails.application.load_seed

    # Need to setup the Redis cache here!
      #  debugger
    Result.set_all_unique_codigo_externo_to_redis
   # CacheLicitacionesData.perform
  end


  test "correctly returns chilecompra data from the database when requested" do

    get_info_params = {
                        startDate: 1,
                        alwaysFromToday: false,
                        alwaysToToday: false,
                        endDate: Time.zone.now().to_i * 1000,
                        offset: 0,
                        order_by: {
                                   fields: [],
                                   order: "descending"}
    }
    post '/get_info', params: get_info_params.to_json, headers: @headers

    parsed_response = JSON.parse(@response.body)

    #Assert that the amount of unique codigo_externos is equal to the amount sent in the response's 
    # "count" key
    assert_equal Result.last_per_codigo_externo.count, parsed_response["count"]

    offset = get_info_params[:offset]
    limit = assigns(:result_limit_amount) 

    #Since with those get_info_params you'll get back all of the records (in sets of @result_limit_amount)
    # we compare ALL codigo_externos with the response
    all_codigos_externos = Result.last_per_codigo_externo
                                 .sort {|a, z| a <=> z}
                                 .map{|result| Result.find(result.id).codigo_externo}
                                 .slice(offset, limit)
    #and here, the Id
    all_ids = Result.all.map {|result| result.id}.sort {|a, z| a<=>z}.slice(offset, limit)

    # The response's codigo_externos
    parsed_response_codigos_externos = parsed_response["values"].map {|resp| resp["value"]["Listado"][0]["CodigoExterno"]}.sort {|a, z| a <=> z}
    # And its ids
    parsed_response_ids = parsed_response["values"].map {|resp| resp["id"]}.sort {|a, z| a<=>z}

    #They should be equal
    assert_equal all_ids, parsed_response_ids
    assert_equal all_codigos_externos - parsed_response_codigos_externos, []
  end


  test "returns error when getting chilecompra data with unpermitted params" do

    get_info_params = {
                        startDate: 1 * 1000,
                        alwaysFromToday: false,
                        alwaysToToday: false,
                        endDate: Time.zone.now().to_i * 1000,
                        offset: 0,
                        order_by: {fields:[]},
                        madeUpParam: "Math.sqrt(-1)"
    }

    post '/get_info', params: get_info_params.to_json, headers: @headers

    assert_response 422
    expected_response = {message: {errors: "Parámetros inválidos"}}.to_json
    assert_equal @response.body, expected_response
  end


  test "correctly returns estados_licitacion when requested" do

    get '/get_misc_info?info=estados_licitacion', headers: @headers

    assert_equal Redis.current.hgetall("estados_licitacion"), JSON.parse(@response.body) 
  end


  test "correctly returns organismos_publicos when requested" do

    get '/get_misc_info?info=organismos_publicos', headers: @headers
    assert_equal Redis.current.hgetall("organismos_publicos"), JSON.parse(@response.body) 
  end


  test "Returns an error when passing random parameters to get_misc_info" do

    headers = sign_in_example_user
    get '/get_misc_info?random_param=random_value', headers: @headers
    assert_response 422
    expected_response = {message: {errors: "Parámetros inválidos"}}.to_json
    assert_equal @response.body, expected_response
  end


  test "Returns an error when passing some other value in the :info param" do

    get '/get_misc_info?info=this_is_not_valid', headers: @headers

    assert_response 422
    expected_response = {message: {errors: "Parámetros inválidos"}}.to_json
    assert_equal @response.body, expected_response
  end

end
