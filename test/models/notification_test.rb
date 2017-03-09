require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
#Notifications are saved through resque jobs using the build in create method
  def setup
    @user = User.create(email: "newemail@newmail.com", password: "password11111111")
    @notification = Notification.create(user_id: @user.id, message: "mock notification")
    @notification2 = Notification.create(user_id: @user.id, message: "mock notification 2")
  end


  test "Should show all notifications of user" do
    response = Notification.show_notifications_of(@user)
    assert_equal response, {@notification.id => @notification.message, 
                            @notification2.id => @notification2.message}
  end

  test "If trying to show notifications of unexistant user, return an error message" do
    assert_equal Notification.show_notifications_of(nil), "Usuario inválido"
  end

  test "Should delete notification with id == notification_id of user" do
  
    assert_difference 'Notification.all.count', -1 do
      Notification.delete_notification_of_user(@user.id, @notification.id)
    end
    assert_difference 'Notification.all.count', -1 do
      Notification.delete_notification_of_user(@user.id, @notification2.id)
    end
  end

  test "Delete notification of user should raise if trying to delete unexistant notification" do

    assert_raise ActiveRecord::RecordNotFound do
      Notification.delete_notification_of_user(nil, nil)
    end

  end

  test "Should delete all notifications of user with id == user_id" do

    Notification.delete_all_notifications_of_user(@user.id)
    assert_equal Notification.show_notifications_of(@user), {}
  end

  test "Delete all notifications of user should raise if no notifications are found" do

    assert_raise ActiveRecord::RecordNotFound do
      Notification.delete_all_notifications_of_user(nil)
    end

  end



end
