class SearchesController < ApplicationController
  include SearchesHelper
  before_action :authenticate_user!
  before_action :search_params, only: :create
  before_action :search_update_params, only: :update
  before_action :search_delete_params, only: :destroy

  def show
    render json: {searches: show_searches(current_user)}
  end

  def create
    render json: create_search(search_params)
  end

  def update
    render json: update_search(search_update_params)
  end

  def destroy
    render json: destroy_search(search_delete_params)
  end

  private

  def search_params
      params.require(:search).permit({:value => [
                                                 :startDate,
                                                 :alwaysFromToday,
                                                 :endDate,
                                                 :alwaysToToday,
                                                 :selectedEstadoLicitacion,
                                                 :organismosPublicosFilter,
                                                 :selectedOrganismoPublico,
                                                 :rutProveedor,
                                                 :codigoLicitacion,
                                                 :palabrasClave,
                                                 :offset,
                                                 :order_by => [
                                                              :order,
                                                              :fields => []
                                                              ]
                                                ]
                                      }, 
                                       :name)
    rescue ActionController::UnpermittedParameters
      return render json: json_message_to_frontend(errors: "Parámetros inválidos"), status: 422
  end

  def search_update_params

    params.require(:search).permit({:newValues => [
                                                   :startDate,
                                                   :alwaysFromToday,
                                                   :endDate,
                                                   :alwaysToToday,
                                                   :selectedEstadoLicitacion,
                                                   :organismosPublicosFilter,
                                                   :selectedOrganismoPublico,
                                                   :rutProveedor,
                                                   :codigoLicitacion,
                                                   :palabrasClave,
                                                   :offset,
                                                   :order_by => [
                                                                 :order,
                                                                 :fields => []
                                                                 ]
                                                   ]
                                    }, 
                                    :searchId, :searchName)
    rescue ActionController::UnpermittedParameters
      return render json: json_message_to_frontend(errors: "Parámetros inválidos"), status: 422
  end

  def search_delete_params
    params.require(:search).permit(:id)
    rescue ActionController::UnpermittedParameters
      return render json: json_message_to_frontend(errors: "Parámetros inválidos"), status: 422
  end


end
