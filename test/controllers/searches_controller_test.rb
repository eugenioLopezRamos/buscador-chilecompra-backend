require 'test_helper'
# rubocop:disable Metrics/ClassLength
class SearchesControllerTest < ActionDispatch::IntegrationTest
  include SearchesHelper
  include ApplicationHelper

  def setup
    @user = User.first
    @headers = sign_in_example_user
  end

  test 'Shows searches correctly' do
    get '/searches', headers: @headers
    expected_response = { "searches": show_searches(@user) }
    assert_response 200
    assert_equal @response.body, expected_response.to_json
  end

  test 'Creates searches correctly' do
    create_search_params = {
      search: {
        value: {
          offset: 0, order_by: { order: 'descending', fields: [] },
          startDate: Time.zone.now.to_i * 1000, rutProveedor: '11111111',
          alwaysToToday: false, palabrasClave: '', alwaysFromToday: false,
          codigoLicitacion: '', organismosPublicosFilter: 'va',
          selectedEstadoLicitacion: '', selectedOrganismoPublico: '7016'
        },
        name: 'mock search'
      }
    }

    assert_difference 'Search.all.count', 1 do
      post '/searches', params: create_search_params.to_json, headers: @headers
    end

    assert_equal @response.body, json_message(
      info: { "guardado con éxito": [create_search_params[:search][:name]] },
      errors: { "repetidos": [], "errores": [] },
      extra: { searches: show_searches(@user) }
    ).to_json

    new_search = Search.find_by(user_id: @user.id,
                                name: create_search_params[:search][:name]).value
    assert_equal new_search.as_json, create_search_params[:search][:value].as_json
  end

  test 'Create search raises when given an invalid param' do
    create_search_params = {
      search: {
        value: {
          offset: 0,
          endDate: Time.zone.now.to_i * 1000,
          order_by: { order: 'descending', fields: [] },
          startDate: Time.zone.now.to_i * 1000,
          rutProveedor: '11111111',
          alwaysToToday: false,
          palabrasClave: '',
          alwaysFromToday: false,
          codigoLicitacion: '',
          organismosPublicosFilter: 'va',
          selectedEstadoLicitacion: '',
          selectedOrganismoPublico: '7016'
        },
        name: 'mock search',
        forbidden_param: 'invalid param'
      }
    }
    assert_no_difference 'Search.all.count' do
      post '/searches', params: create_search_params.to_json, headers: @headers
    end
    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Create search raises when no user auth headers are given' do
    create_search_params = {
      search: {
        value: {
          offset: 0, endDate: Time.zone.now.to_i * 1000,
          order_by: { order: 'descending', fields: [] },
          startDate: Time.zone.now.to_i * 1000,
          rutProveedor: '11111111', alwaysToToday: false,
          palabrasClave: '', alwaysFromToday: false,
          codigoLicitacion: '', organismosPublicosFilter: 'va',
          selectedEstadoLicitacion: '', selectedOrganismoPublico: '7016'
        },
        name: 'mock search'
      }
    }

    assert_no_difference 'Search.all.count' do
      post '/searches', params: create_search_params.to_json
    end

    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
    assert_response 401
  end

  test 'Updates searches correctly' do
    search_id = Search.first.id
    search_name = Search.first.name

    update_search_params = {
      search: {
        newValues: {
          rutProveedor: '2222', order_by: { order: 'ascending', fields: [] },
          offset: 0, endDate: Time.zone.now.to_i * 1000,
          startDate: Time.zone.now.to_i * 1000, alwaysToToday: false,
          palabrasClave: '', alwaysFromToday: false, codigoLicitacion: '',
          organismosPublicosFilter: 'va', selectedEstadoLicitacion: '',
          selectedOrganismoPublico: '7016'
        },
        searchName: search_name,
        searchId: search_id
      }
    }
    assert_no_difference 'Search.all.count' do
      put '/searches', params: update_search_params.to_json, headers: @headers
    end

    assert_response 200
    assert_equal @response.body, json_message(
      info: { "Modificado exitosamente": [update_search_params[:search][:searchName]] },
      extra: { searches: show_searches(@user) }
    ).to_json
  end

  test 'Update search raises when given unpermitted params' do
    search_id = Search.first.id
    search_name = Search.first.name

    update_search_params = {
      search: {
        newValues: {
          rutProveedor: '2222', order_by: { order: 'ascending', fields: [] },
          offset: 0, endDate: Time.zone.now.to_i * 1000,
          startDate: Time.zone.now.to_i * 1000, alwaysToToday: false,
          palabrasClave: '', alwaysFromToday: false,
          codigoLicitacion: '', organismosPublicosFilter: 'va',
          selectedEstadoLicitacion: '', selectedOrganismoPublico: '7016'
        },
        searchName: search_name,
        searchId: search_id,
        forbidden_param: 'i am unpermitted'
      }
    }

    assert_no_difference 'Search.all.count' do
      put '/searches', params: update_search_params.to_json, headers: @headers
    end

    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Update search raises when given no user auth headers' do
    search_id = Search.first.id
    search_name = Search.first.name

    update_search_params = {
      search: {
        newValues: {
          rutProveedor: '2222', order_by: { order: 'ascending', fields: [] },
          offset: 0, endDate: Time.zone.now.to_i * 1000,
          startDate: Time.zone.now.to_i * 1000, alwaysToToday: false,
          palabrasClave: '', alwaysFromToday: false, codigoLicitacion: '',
          organismosPublicosFilter: 'va', selectedEstadoLicitacion: '',
          selectedOrganismoPublico: '7016'
        },
        searchName: search_name,
        searchId: search_id
      }
    }
    assert_no_difference 'Search.all.count' do
      put '/searches', params: update_search_params.to_json
    end

    assert_response 401
    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
  end

  test 'Destroys searches correctly' do
    search_id = Search.first.id
    search_name = Search.first.name
    delete_search_params = {
      search: { id: search_id }
    }
    assert_difference 'Search.all.count', -1 do
      delete '/searches', params: delete_search_params.to_json, headers: @headers
    end

    assert_response 200
    assert_equal @response.body, json_message(
      info: { "Borrado exitosamente": [search_name] },
      extra: { searches: show_searches(@user) }
    ).to_json
  end

  test 'Destroy search raises when given unpermitted params' do
    search_id = Search.first.id
    delete_search_params = {
      search: { id: search_id, whatever: 'param data goes here' }
    }
    assert_no_difference 'Search.all.count' do
      delete '/searches', params: delete_search_params.to_json, headers: @headers
    end

    assert_response 422
    assert_equal @response.body, json_message(errors: 'Parámetros inválidos').to_json
  end

  test 'Destroy search raises when given no user auth headers' do
    search_id = Search.first.id
    delete_search_params = {
      search: { id: search_id }
    }
    assert_no_difference 'Search.all.count' do
      delete '/searches', params: delete_search_params.to_json
    end
    assert_response 401
    assert_equal @response.body, json_message(errors: 'Acceso denegado. Por favor ingresa.').to_json
  end
end
# rubocop:enable Metrics/ClassLength
