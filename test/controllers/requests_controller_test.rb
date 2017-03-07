require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest

  def setup
    #Will probably have to mock the redis values?
    @first_result = Result.first
    @user = User.first
  #  Rails.application.load_seed
  end


  test "correctly returns chilecompra data from the database when requested" do
    headers = sign_in_example_user

    get_info_params = {
                        startDate: 1 * 1000,
                        alwaysFromToday: false,
                        alwaysToToday: false,
                        endDate: Time.zone.now().to_i * 1000,
                        offset: 0,
                        order_by: {fields:[]}
    }
    post '/get_info', params: get_info_params.to_json, headers: headers

    parsed_response = JSON.parse(@response.body)

    assert_equal Result.all.count, parsed_response["count"]

    #TODO: Check what happens here
    #There's some kind of trouble when with .created_at, .updated_at when
    #transforming to json (dates are transformed differently), 
    #so I'll test value and id for now
    
    all_values = Result.all.map {|result| result.value}
    all_ids = Result.all.map {|result| result.id}

    parsed_values = parsed_response["values"].map {|resp| resp["value"]}
    parsed_ids = parsed_response["values"].map {|resp| resp["id"]}
    assert_equal all_values, parsed_values
    assert_equal all_ids, parsed_ids
  end


  test "returns error when getting chilecompra data with unpermitted params" do
    headers = sign_in_example_user
    get_info_params = {
                        startDate: 1 * 1000,
                        alwaysFromToday: false,
                        alwaysToToday: false,
                        endDate: Time.zone.now().to_i * 1000,
                        offset: 0,
                        order_by: {fields:[]},
                        madeUpParam: "Math.sqrt(-1)"
    }

    post '/get_info', params: get_info_params.to_json, headers: headers

    assert_response 422
    expected_response = {message: {errors: "Parámetros inválidos"}}.to_json
    assert_equal @response.body, expected_response
  end


  test "correctly returns estados_licitacion when requested" do
    headers = sign_in_example_user

    get '/get_misc_info?info=estados_licitacion', headers: headers

    assert_equal Redis.current.hgetall("estados_licitacion"), JSON.parse(@response.body) 
  end


  test "correctly returns organismos_publicos when requested" do
    headers = sign_in_example_user

    get '/get_misc_info?info=organismos_publicos', headers: headers
    assert_equal Redis.current.hgetall("organismos_publicos"), JSON.parse(@response.body) 
  end


  test "Returns an error when passing random parameters to get_misc_info" do
    headers = sign_in_example_user
    get '/get_misc_info?random_param=random_value', headers: headers
    assert_response 422
    expected_response = {message: {errors: "Parámetros inválidos"}}.to_json
    assert_equal @response.body, expected_response
  end


  test "Returns an error when passing some other value in the :info param" do
    headers = sign_in_example_user

    get '/get_misc_info?info=this_is_not_valid', headers: headers

    assert_response 422
    expected_response = {message: {errors: "Parámetros inválidos"}}.to_json
    assert_equal @response.body, expected_response
  end

end
