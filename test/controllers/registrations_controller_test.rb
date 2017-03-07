require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest

  #The only extra method we use here is render_update_error,
  # which happens when failing to update the user's info 
  #(because he/she didn't insert his/her password, for example)

  def setup
    @user = User.first
  end

  test "When account update fails, get a customized error message" do
    
    headers = sign_in_example_user
    old_name = @user.name
    put '/auth/', params: {current_password: "wrongpassword", name: "AnotherName"}.to_json, headers: headers
    
    expected_response = {message: {errors:  "No se pudo actualizar. Ingresaste tu contraseña?"}}
    assert_response 422
    assert_equal expected_response.to_json, @response.body
  
  end

end
