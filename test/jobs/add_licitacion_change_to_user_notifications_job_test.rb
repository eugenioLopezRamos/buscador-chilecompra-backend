require 'test_helper'

class AddLicitacionChangeToUserNotificationsJobTest < ActiveJob::TestCase

  def setup
    @notification_emails_cache = Redis.current.hgetall("notification_emails")
    @result = Result.first
    @codigo_externo = @result.codigo_externo
    @class = AddLicitacionChangeToUserNotifications
    @user = User.first
  end

  test "Correctly gets users to be notified about a licitacion changing" do
    
    if !@user.subscribed_to_result? @result.id
      @user.subscribe_to_result(@result.id, "mock")
    end

    assert @user.subscribed_to_result? @result.id
    assert_equal [@user.id], @class.get_users_to_notify(@codigo_externo)
  end

  test "Correctly creates a user's notification" do
    #clear notification emails registry
  
    Redis.current.DEL("notification_emails")
    assert_equal Hash.new, Redis.current.hgetall("notification_emails")

    #get users to be emailed
    users = @class.get_users_to_notify(@codigo_externo)
    
    #do it create notifications?
    assert_difference 'Notification.count', 1 do
      @class.create_users_notification(@codigo_externo, users)
    end
    
    #Name of the subscription we're informing the user about
    sub_name = User.find(users.first).subscriptions_by_codigo_externo.key(@codigo_externo)

    #Message to be added to the redis hash
    expected_message = "Cambios en la suscripción #{sub_name} (cod.#{@codigo_externo})"
    #key:value pair to be added to Redis.current "notification_emails" hash
    expected_result = {"#{users.first.to_s}": expected_message + "\n"}

    assert_equal expected_result.as_json, Redis.current.hgetall("notification_emails")
  end

  test "Correctly performs the job when there are still licitaciones to get" do
    #Yes, there is a bit of testing duplication here but I think it's worth it since
    #we should do it anyways since #perform is the most important method
    #Another option would be to simply collapse all testing in this test
    #since the other methods are simply helpers
    
    #Mock a non empty :licitaciones queue so the notif email sender doesn't get sent
    Resque::Job.create(:licitaciones, 'DoesntExist')
    Redis.current.DEL("notification_emails")

    assert_equal Hash.new, Redis.current.hgetall("notification_emails")

    if !@user.subscribed_to_result? @result.id
      @user.subscribe_to_result(@result.id, "mock")
    end

    assert_difference 'Notification.count', 1 do
      @class.perform(@codigo_externo)
    end

    users = @class.get_users_to_notify(@codigo_externo)
    #Name of the subscription we're informing the user about
    sub_name = User.find(users.first).subscriptions_by_codigo_externo.key(@codigo_externo)
    #Message to be added to the redis hash
    expected_message = "Cambios en la suscripción #{sub_name} (cod.#{@codigo_externo})"
    #key:value pair to be added to Redis.current "notification_emails" hash
    expected_result = {"#{users.first.to_s}": expected_message + "\n"}

    assert_equal expected_result.as_json, Redis.current.hgetall("notification_emails")

    assert_equal 1, Resque.queue_sizes["licitaciones"]

    #Destroy the mock job
    Resque::Job.destroy(:licitaciones, 'DoesntExist')
    assert_equal 0, Resque.queue_sizes["licitaciones"]
  end

  test "Correctly performs the job when no licitaciones are left to get" do

  end

end
