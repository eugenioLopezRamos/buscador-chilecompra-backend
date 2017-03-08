require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
include SearchesHelper
#TODO: Just use fixtures instead of seeds...

  def setup
    @user = User.first
    @headers = sign_in_example_user
  end

  test "Shows searches correctly" do

    get '/searches', headers: @headers
    expected_response = {"searches": show_searches(@user)}
    assert_response 200
    assert_equal @response.body, expected_response.to_json

  end


  test "Creates searches correctly" do



  end

  test "Updates searches correctly" do

  end

  
  test "Destroys searches correctly" do



  end



end
