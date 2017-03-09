require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = User.first
    @notif = Notification.create(user_id: @user.id, message: "Mock notif")
    @notif.save!
    @headers = sign_in_example_user
  end

  test "Notifications#show shows current_user's notifications" do

    get '/notifications', headers: @headers
    #need to use .to_json to mock the presentation of "response"
    assert_equal @user.show_notifications.to_json, @response.body
    assert_response 200
  end

  test "Notifications#show fails if given no user auth headers" do

    get '/notifications'
    assert_equal @response.body, json_message_to_frontend(errors: "Acceso denegado. Por favor ingresa.").to_json
    assert_response 401

  end

  test "Notifications#destroy destroy's current_users notification according to given notif id" do

    assert_difference 'Notification.all.count', -1 do
      delete '/notifications', params: {notification: {notification_id: @notif.id}}.to_json, headers: @headers
    end
    expected_response = {message: {info: "Notificación borrada con éxito"}, notifications: @user.show_notifications}
    assert_equal expected_response.to_json, @response.body
    assert_response 200
  end

  test "Notifications#destroy raises if notification is not found" do

    assert_no_difference 'Notification.all.count' do
      delete '/notifications', params: {notification: {notification_id: 99999}}.to_json, headers: @headers
    end

    assert_equal @response.body, json_message_to_frontend(errors: "No se encontró dicha notificación").to_json
    assert_response 404

  end

  test "Notifications#destroy raises if given incorrect params" do
    notification_params = {notification: {id: 99999, invalid_param: "not valid"}}

    assert_no_difference 'Notification.all.count' do
      delete '/notifications', params: notification_params.to_json, headers: @headers
    end

    assert_response 422
    assert_equal @response.body, json_message_to_frontend(errors: "Parámetros inválidos").to_json


  end


end
