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
    #Yes, there is a bit of testing duplication here but I think it's worth it since
    #we should do it anyways since #perform is the most important method
    #Another option would be to simply collapse all testing in this test
    #since the other methods are simply helpers

   # Redis.current.DEL("notification_emails")

   # assert_equal Hash.new, Redis.current.hgetall("notification_emails")

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

    users = @class.get_users_to_notify(@codigo_externo)
    #Name of the subscription we're informing the user about
    sub_name = User.find(users.first).subscriptions_by_codigo_externo.key(@codigo_externo)
    #Message to be added to the redis hash
    expected_message = "Cambios en la suscripción #{sub_name} (cod.#{@codigo_externo})"
    #key:value pair to be added to Redis.current "notification_emails" hash
    expected_result = {"#{users.first.to_s}": expected_message + "\n"}

    assert_equal expected_result.as_json, Redis.current.hgetall("notification_emails")

   # assert_equal 1, Resque.size("licitaciones")

    #Destroy the mock job
  #  Resque::Job.destroy(:licitaciones, 'MockJob')
   # assert_equal 0, Resque.queue_sizes["licitaciones"]
  end

  test "Correctly performs the job when no licitaciones are left to get" do

    # #If there are jobs, move them to a temp queue that has no workers assigned 
    # #to be restored after testing
    # #(useful in case you have the actual jobs running on dev and run the tests,
    # # you can test this successfully and not lose your jobs)
    
    #   #clear the mock queue
    # Resque.redis.del "queue:#{"mockqueue"}"


    # Resque::Job.create(:licitaciones, 'MockJob')
    # Resque::Job.create(:licitaciones, 'MockJob')
    # Resque::Job.create(:licitaciones, 'MockJob')
    # Resque::Job.create(:licitaciones, 'MockJob')

    # if Resque.queue_sizes["licitaciones"] != 0
    #   old_jobs = []
    #   while(Resque.queue_sizes["licitaciones"] > 0) do
    #     position = Resque.queue_sizes["licitaciones"] - 1
    #     job = Resque.pop(:licitaciones)
    #     old_jobs[position] = job
    #   end
    #   old_jobs.each do |job|
    #     Resque::Job.create(:mockqueue, job)
    #   end
    # end 

    # Redis.current.DEL("notification_emails")

    # assert_equal Hash.new, Redis.current.hgetall("notification_emails")

    # if !@user.subscribed_to_result? @result.id
    #   @user.subscribe_to_result(@result.id, "mock")
    # end

    # assert_difference 'Notification.count', 1 do
    #   @class.perform(@codigo_externo)
    # end

    # users = @class.get_users_to_notify(@codigo_externo)
    # #Name of the subscription we're informing the user about
    # sub_name = User.find(users.first).subscriptions_by_codigo_externo.key(@codigo_externo)
    # #Message to be added to the redis hash
    # expected_message = "Cambios en la suscripción #{sub_name} (cod.#{@codigo_externo})"
    # #key:value pair to be added to Redis.current "notification_emails" hash
    # expected_result = {"#{users.first.to_s}": expected_message + "\n"}

    # assert_equal expected_result.as_json, Redis.current.hgetall("notification_emails")

    # assert_equal 4, Resque.queue_sizes["mockqueue"]

    # if Resque.queue_sizes["mockqueue"] != 0
    #   old_jobs = []
    #   while(Resque.queue_sizes["mockqueue"] > 0) do
    #     position = Resque.queue_sizes["mockqueue"] - 1
    #     job = Resque.pop(:mockqueue)
    #     old_jobs[position] = job
    #   end
    #   old_jobs.each do |job|
    #     Resque::Job.create(:licitaciones, job)
    #   end
    #   #clear the mock queue
    # Resque.redis.del "queue:#{"mockqueue"}"
    # end


    # assert_equal 0, Resque.queue_sizes["mockqueue"]
    # assert_equal 4, Resque.queue_sizes["licitaciones"]

  end

end
