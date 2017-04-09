require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # TODO: Do this!
  include SearchesHelper

  def setup
    @class = User
    @user = @class.first
    @subbed_result = @user.subscriptions.values.first
    @not_subbed_result = Result.last
    @test_subscription = ActiveRecord::Base.connection.execute('
                                                                SELECT *
                                                                FROM "user_results"
                                                                WHERE "user_id" = ' + @user.id.to_s + '
                                                              ')
                                           .as_json.first
  end

  test 'Gets all data related to a user' do
    expected_response = {}
    expected_response[:user] = @user.as_json
    expected_response[:searches] = show_searches(@user)
    expected_response[:subscriptions] = @user.subscriptions
    expected_response[:notifications] = @user.show_notifications

    assert_equal expected_response.as_json, @user.all_related_data.as_json
  end

  test "Gets a user's subscriptions" do
    assert_equal UserResult.of_user(@user), @user.subscriptions
  end

  test "Gets a user's subscriptions by codigo_externo" do
    assert_equal UserResult.subscriptions_by_codigo_externo_of(@user), @user.subscriptions_by_codigo_externo
  end

  test 'Checks if user is subscribed to result_id' do
    assert @user.subscribed_to_result? @subbed_result
    assert_not @user.subscribed_to_result? @not_subbed_result.id
  end

  test 'Subscribes user to result_id' do
    assert_equal false, @user.subscribed_to_result?(@not_subbed_result.id)

    @user.subscribe_to_result(@not_subbed_result.id, 'test sub')

    assert @user.subscribed_to_result?(@not_subbed_result.id)
  end

  test 'Updates subscription' do
    old_name = @test_subscription['subscription_name']
    new_name = 'new test sub name'
    @user.update_result_subscription(old_name, new_name)

    assert_not_equal old_name, UserResult.find(@test_subscription['id']).subscription_name
    assert_equal new_name, UserResult.find(@test_subscription['id']).subscription_name
  end

  test 'Destroys user subscription' do
    @user.destroy_result_subscription(@test_subscription['subscription_name'])

    assert_raise ActiveRecord::RecordNotFound do
      UserResult.find(@test_subscription['id'])
    end
  end

  test 'Show notifications of user' do
    expected_notifications = ActiveRecord::Base.connection.execute('
                                                                    SELECT *
                                                                    FROM "notifications"
                                                                    WHERE "user_id" = ' + @user.id.to_s + '
                                                                    ').as_json

    assert_equal 1, expected_notifications.length
    assert_equal expected_notifications.length, @user.notifications.as_json.length
    assert_equal expected_notifications[0]['id'], @user.notifications.as_json[0]['id']
    assert_equal expected_notifications[0]['message'], @user.notifications.as_json[0]['message']
    assert_equal expected_notifications[0]['user_id'], @user.notifications.as_json[0]['user_id']
  end

  test 'Destroy notification with id notification_id of user' do
    notification = @user.notifications.as_json.first

    @user.destroy_notification notification['id']

    assert_raise ActiveRecord::RecordNotFound do
      Notification.find(notification['id'])
    end
  end

  test 'Destroys all notifications of user' do
    @user.destroy_all_notifications

    assert_equal [], @user.notifications.as_json
  end

  # test private method add_user_to_mailing_list
end
