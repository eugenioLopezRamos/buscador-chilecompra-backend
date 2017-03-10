require 'test_helper'
#TODO: Is it better to move/split all of these controller tests to integration? seems like a mostly cosmetic change

class ApplicationControllerTest < ActionDispatch::IntegrationTest
#TODO: remove this, it's tested on the rest of the controllers anyways.
  def setup
    @user = User.first
  end

  #In these tests, '/searches' is used merely as an example
  # We test authenticate_user! rejecting or accepting user's as expected
  test "Returns an error message if current_user is nil" do
    get '/searches'
    assert_response 401, errors: "Acceso denegado. Por favor ingresa."
  end

  test "Returns OK if user is actually logged in" do
    headers = sign_in_example_user
    get '/searches', headers: headers
    assert_response 200
  end

end
