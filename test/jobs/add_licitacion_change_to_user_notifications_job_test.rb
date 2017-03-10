require 'test_helper'

class AddLicitacionChangeToUserNotificationsJobTest < ActiveJob::TestCase

  def setup
    @notification_emails_cache = Redis.current.hgetall("notification_emails")
    @codigo_externo = Result.first.codigo_externo
    @class = AddLicitacionChangeToUserNotifications
  end

  test "Correctly gets users to be notified about a licitacion changing" do

    assert_equal [User.first.id], @class.get_users_to_notify(@codigo_externo)




  end

  test "Correctly creates a user's notification" do



  end

  test "Correctly performs the job" do



  end



end
