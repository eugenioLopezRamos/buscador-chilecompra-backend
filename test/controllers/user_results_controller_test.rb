require 'test_helper'

class UserResultsControllerTest < ActionDispatch::IntegrationTest
  include UserResultsHelper
  include ApplicationHelper

  def setup
    @user = User.first
    @headers = sign_in_example_user
  end

  test "Show shows the user's subscriptions" do
    get '/results/subscriptions', headers: @headers
    assert_response 200
    assert_equal @response.body, @user.subscriptions.to_json
  end

  test 'Show raises when given no user auth headers' do
    get '/results/subscriptions'

    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
    assert_response 401
  end

  test 'Creates a new subscription' do
    result_id = Result.last.id

    create_user_result_params = {
      create_subscription: {
        name: 'mock_name',
        result_id: result_id
      }
    }

    assert_difference 'UserResult.all.count', 1 do
      post '/results/subscriptions', params: create_user_result_params.to_json, headers: @headers
    end

    assert_response 200
    assert_equal @response.body, json_message(info: 'Suscripción guardada exitosamente',
                                                          extra: { subscriptions: @user.subscriptions }).to_json
  end

  test 'Create raises when given invalid params' do
    result_id = Result.last.id

    create_user_result_params = {
      create_subscription: {
        name: 'mock_name',
        result_id: result_id,
        totally_random_param: 'aaaaaa'
      }
    }

    assert_no_difference 'UserResult.all.count' do
      post '/results/subscriptions', params: create_user_result_params.to_json, headers: @headers
    end

    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Create raises when subscribing to an already subscribed-to result' do
    result_id = Result.first.id
    result_codigo_externo = Result.first.value['Listado'][0]['CodigoExterno']
    already_subscribed = UserResult.where(result_id: result_id).first

    create_user_result_params = {
      create_subscription: {
        name: 'mock_name',
        result_id: result_id
      }
    }
    assert_no_difference 'UserResult.all.count' do
      post '/results/subscriptions', params: create_user_result_params.to_json, headers: @headers
    end

    expected_error_message = "Ya estás suscrito a la licitacion de código externo #{result_codigo_externo} (Nombre suscripción: #{already_subscribed.subscription_name})"
    assert_response 422
    assert_equal @response.body, json_message(errors: expected_error_message).to_json
  end

  test 'Create raises when given no user auth headers' do
    result_id = Result.last.id
    create_user_result_params = {
      create_subscription: {
        name: 'mock_name',
        result_id: result_id
      }
    }

    assert_no_difference 'UserResult.all.count' do
      post '/results/subscriptions', params: create_user_result_params.to_json
    end

    assert_response 401
    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
  end

  test 'Updates a subscription' do
    # Save as json to save as value instead of ref
    old_subscription = UserResult.first.to_json
    old_name = UserResult.first.subscription_name

    update_user_result_params = {
      update_subscription: {
        old_name: old_name,
        name: 'name 2.0'
      }
    }

    assert_no_difference 'UserResult.all.count' do
      put '/results/subscriptions', params: update_user_result_params.to_json, headers: @headers
    end

    assert_not_equal old_subscription, UserResult.first.to_json
    assert_response 200
    assert_equal @response.body, json_message(info: 'Actualizado exitosamente',
                                                          extra: { subscriptions: @user.subscriptions }).to_json
  end

  test 'Update raises when given invalid params' do
    old_subscription = UserResult.first.to_json
    old_name = UserResult.first.subscription_name

    update_user_result_params = {
      update_subscription: {
        old_name: old_name,
        name: 'name 2.0',
        not_supposed_to_be_here: 'hide me'
      }
    }

    assert_no_difference 'UserResult.all.count' do
      put '/results/subscriptions', params: update_user_result_params.to_json, headers: @headers
    end

    assert_equal old_subscription, UserResult.first.to_json
    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Update raises when given no user auth headers' do
    old_subscription = UserResult.first.to_json
    old_name = UserResult.first.subscription_name

    update_user_result_params = {
      update_subscription: {
        old_name: old_name,
        name: 'name 2.0'
      }
    }
    assert_no_difference 'UserResult.all.count' do
      put '/results/subscriptions', params: update_user_result_params.to_json
    end
    assert_equal old_subscription, UserResult.first.to_json

    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
    assert_response 401
  end

  test 'Destroys a subscription' do
    subscription_name = UserResult.first.subscription_name

    delete_user_result_params = {
      destroy_subscription: {
        name: subscription_name
      }
    }

    assert_difference 'UserResult.all.count', -1 do
      delete '/results/subscriptions', params: delete_user_result_params.to_json, headers: @headers
    end

    assert_response 200
    assert_equal @response.body, json_message(info: 'Suscripción cancelada exitosamente',
                                                          extra: { subscriptions: @user.subscriptions }).to_json
  end

  test 'Destroy raises when given invalid params' do
    subscription_name = UserResult.first.subscription_name
    delete_user_result_params = {
      destroy_subscription: {
        name: subscription_name,
        forbidden_param: 'aaaa'
      }
    }
    assert_no_difference 'UserResult.all.count' do
      delete '/results/subscriptions', params: delete_user_result_params.to_json, headers: @headers
    end

    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Destroy raises when given no user auth headers' do
    subscription_name = UserResult.first.subscription_name

    delete_user_result_params = {
      destroy_subscription: {
        name: subscription_name
      }
    }
    assert_no_difference 'UserResult.all.count' do
      delete '/results/subscriptions', params: delete_user_result_params.to_json
    end

    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
    assert_response 401
  end

  test 'Result history shows a results history' do
    result_id = UserResult.first.user_id

    show_history_params = {
      id: result_id
    }
    # .to_json not needed here. Makes no diff in real use
    get '/results/history', params: show_history_params, headers: @headers

    assert_response 200
    assert_equal @response.body, Result.find(result_id).history.to_json
  end

  test 'Result history raises when given invalid params' do
    result_id = UserResult.first.user_id

    show_history_params = {
      id: result_id,
      invalid_param: '1/0'
    }
    # .to_json not needed here. Makes no diff in real use
    get '/results/history', params: show_history_params, headers: @headers

    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Result history raises when given no user auth headers' do
    result_id = UserResult.first.user_id

    show_history_params = {
      id: result_id
    }
    # .to_json not needed here. Makes no diff in real use
    get '/results/history', params: show_history_params
    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
    assert_response 401
  end
end
