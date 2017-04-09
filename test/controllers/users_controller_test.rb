require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = User.first
    @headers = sign_in_example_user
  end

  test "returns all of the user's data" do
    get '/user', headers: @headers
    expected_response = JSON.parse(@user.all_related_data.to_json)
    parsed_response = JSON.parse(@response.body)

    assert_response 200
    assert_equal expected_response['searches'], parsed_response['searches']
    assert_equal expected_response['subscriptions'], parsed_response['subscriptions']
    assert_equal expected_response['notifications'], parsed_response['notifications']

    # compared by id because weird stuff happens regarding with the "updated at"
    # field
    assert_equal expected_response['user']['id'], parsed_response['user']['id']
  end

  test 'fails when given no auth headers' do
    get '/user', headers: nil
    assert_response 401

    expected_response = json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
    assert_equal expected_response, @response.body
  end
end
