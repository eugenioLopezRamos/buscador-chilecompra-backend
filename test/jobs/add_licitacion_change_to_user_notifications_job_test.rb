require 'test_helper'

class MockJob
  @queue = :licitaciones
  def self.perform
    puts "hello world"
  end
end

class AddLicitacionChangeToUserNotificationsJobTest < ActiveJob::TestCase

  def setup
    @notification_emails_cache = Redis.current.hgetall("notification_emails")
    @result = Result.first
    @codigo_externo = @result.codigo_externo
    @class = AddLicitacionChangeToUserNotifications
    @user = User.first
    Resque.reset!
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

#TODO: Check enqueueing
  test "Correctly performs the job when there are still licitaciones to get" do
    #Yes, there is a bit of testing duplication here but I think 
    #we should do it anyways because #perform is the most important method
    #(and we need to test that LicitacionChangeMailEnqueuer gets enqueued)
    #Another option would be to simply collapse all testing in this test
    #since the other methods are just helpers

    Redis.current.DEL("notification_emails")
    assert_equal Hash.new, Redis.current.hgetall("notification_emails")

    if !@user.subscribed_to_result? @result.id
      @user.subscribe_to_result(@result.id, "mock")
    end

    assert_difference ['Notification.count', 'Redis.current.hgetall("notification_emails").values.length'], 1 do
      #Mocks there being a job in :licitaciones so 
      # it tests when it DOESNT send the email
      Resque.enqueue(MockJob)
      assert_queued(MockJob)
      @class.perform(@codigo_externo)
    end

    assert_not_queued LicitacionChangeMailEnqueuer

    users = @class.get_users_to_notify(@codigo_externo)
    #Name of the subscription we're informing the user about
    sub_name = User.find(users.first).subscriptions_by_codigo_externo.key(@codigo_externo)
    #Message to be added to the redis hash
    expected_message = "Cambios en la suscripción #{sub_name} (cod.#{@codigo_externo})"
    #key:value pair to be added to Redis.current "notification_emails" hash
    expected_result = {"#{users.first.to_s}": expected_message + "\n"}
    assert_equal expected_result.as_json, Redis.current.hgetall("notification_emails")
  end

  test "Correctly performs the job when no licitaciones are left to get" do

    Redis.current.DEL("notification_emails")
    assert_equal Hash.new, Redis.current.hgetall("notification_emails")

    if !@user.subscribed_to_result? @result.id
      @user.subscribe_to_result(@result.id, "mock")
    end

    assert_difference ['Notification.count', 'Redis.current.hgetall("notification_emails").values.length'], 1 do
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
    assert_queued LicitacionChangeMailEnqueuer

  end

end
