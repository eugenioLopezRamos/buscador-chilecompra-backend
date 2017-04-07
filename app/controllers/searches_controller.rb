# Handles earches that the user saves for later reference
class SearchesController < ApplicationController
  include SearchesHelper
  before_action :authenticate_user!
  before_action :search_params, only: :create
  before_action :search_update_params, only: :update
  before_action :search_delete_params, only: :destroy

  def show
    render json: { searches: show_searches(current_user) }
  end

  def create
    response = { successful: [], not_uniq: [], errors: [] }
    populate_response(response, search_params)
    render json: json_message(info: { "guardado con éxito": response[:successful] },
                              errors: { "repetidos": response[:not_uniq],
                                        "errores": response[:errors] },
                              extra: { searches: show_searches(current_user) })
  end

  def update
    search = search_update_params
    name = search[:searchName]
    current_user.searches
                .find_by(name: name)
                .update_attributes(value: search[:newValues], name: name)

    render json: json_message(info: { "Modificado exitosamente": [name] },
                              extra: { searches: show_searches(current_user) })

  rescue ActiveRecord::ActiveRecordError
    render json: json_message(errors: 'Error al guardar cambios, por favor intentalo de nuevo'), status: 500
  end

  def destroy
    search = Search.find_by(user_id: current_user.id,
                            id: search_delete_params[:id])
    if search.destroy
      return render json: json_message(info: { "Borrado exitosamente": [search.name] },
                                       extra: { searches: show_searches(current_user) })
    end
    render json: json_message(errors: { "Fallido": [search.name] },
                              extra: { searches: show_searches(current_user) }), status: 500
  end

  private

  def search_params
    params.require(:search)
          .permit({
                    value: [:startDate, :alwaysFromToday, :endDate, :alwaysToToday,
                            :selectedEstadoLicitacion, :organismosPublicosFilter,
                            :selectedOrganismoPublico, :rutProveedor, :codigoLicitacion,
                            :palabrasClave, :offset, order_by: [:order, fields: []]]
                  },
                  :name)
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    return render json: json_message(errors: 'Parámetros inválidos'), status: 422
  end

  def search_update_params
    params.require(:search)
          .permit({
                    newValues: [:startDate, :alwaysFromToday, :endDate, :alwaysToToday,
                                :selectedEstadoLicitacion, :organismosPublicosFilter,
                                :selectedOrganismoPublico, :rutProveedor,
                                :codigoLicitacion, :palabrasClave, :offset,
                                order_by: [:order, fields: []]]
                  }, :searchId, :searchName)
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    return render json: json_message(errors: 'Parámetros inválidos'), status: 422
  end

  def search_delete_params
    params.require(:search).permit(:id)
  rescue ActionController::UnpermittedParameters
    return render json: json_message(errors: 'Parámetros inválidos'), status: 422
  end
end
