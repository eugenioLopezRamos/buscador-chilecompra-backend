require 'test_helper'

class UserResultTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @connection = ActiveRecord::Base.connection
  end

  test "Should return user results of user" do
    test_result = UserResult.of_user(@user)

    sql_result = @connection.execute('
                                      SELECT "user_results"."subscription_name", "user_results"."id"
                                      FROM "user_results"
                                      WHERE "user_id" = ' + "\'#{@user.id}\'" + '
                                      AND "subscribed" = true
                                     ')

    sql_result = sql_result.reduce({}) do |accumulator, current|
                                current.each_pair do
                                  accumulator[current["subscription_name"]] = current["id"]
                                end
                                accumulator
                            end

    assert_equal sql_result, test_result.as_json
  end

  test "Should return whether the user is subscribed to a result" do
    #user is not subscribed to this one
    new_user_result = UserResult.create(user_id: 9999999, result_id: Result.last.id)
    #but is subbed to this one
    test_subscribed_result = UserResult.where(user_id: @user.id).first

    assert UserResult.user_subscribed_to? @user, test_subscribed_result.id
    assert_not UserResult.user_subscribed_to? @user, new_user_result.id

  end

  test "Should return user's subscriptions by codigo_externo" do

    test_result = UserResult.subscriptions_by_codigo_externo_of @user
    #Do an inner join of user_results & results then reduce the resulting array of hashes into a single hash
    sql_result = @connection.execute('
                                      SELECT "user_results"."subscription_name",
                                             "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' AS "codigo_externo"
                                      FROM "user_results"
                                      INNER JOIN "results"
                                      ON "user_results"."result_id" = "results"."id" 
                                     ')
                             .reduce({}) do |result, current_hash|
                                name = current_hash["subscription_name"]
                                codigo_externo = current_hash["codigo_externo"]
                                result[name] = codigo_externo
                                result
                              end
          
    assert_equal sql_result, test_result.as_json

  end

  test "Should update subscription of user" do

    test_result = UserResult.where(user_id: @user.id).first
    original_name = test_result.subscription_name
    new_name = "another newer name"
    UserResult.update_subscription_of(@user, original_name, new_name)

    assert_equal new_name, UserResult.where(user_id: @user.id).first.subscription_name
    assert_not_equal new_name, original_name

  end


  test "Should subscribe user to result" do
    #use Result.last.value as a mock since it checks codigo_externo in the value json
    mock_result = Result.create(value: Result.last.value)
    new_subscription_name = "new sub name"
    UserResult.subscribe_user_to_result(@user, mock_result.id, new_subscription_name)

    assert UserResult.user_subscribed_to? @user, mock_result.id
  end


  test "Should delete a user's subscription" do
    sub = UserResult.where(user_id: @user.id).first
    sub_name = sub.subscription_name

    old_user_results_amount = UserResult.all.count
    
    UserResult.delete_user_subscription(@user, sub_name)

    assert_equal UserResult.all.count, old_user_results_amount - 1

  end



end
