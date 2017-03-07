require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.first
    @notif = Notification.create(user_id: @user.id, message: "Mock notif")
    @notif.save!
  end

  test "Notifications#show shows current_user's notifications" do

    headers = sign_in_example_user
    get '/notifications', headers: headers
    #need to use .to_json to mock the presentation of "response"
    assert_equal @user.show_notifications.to_json, @response.body

  end

  test "Notifications#destroy destroy's current_users notification according to given notif id" do

    headers = sign_in_example_user
    delete '/notifications', params: {notification: {notification_id: @notif.id}}.to_json, headers: headers
    expected_response = {message: {info: "Notificación borrada con éxito"}, notifications: @user.show_notifications}
    assert_equal expected_response.to_json, @response.body
    
  end



end
