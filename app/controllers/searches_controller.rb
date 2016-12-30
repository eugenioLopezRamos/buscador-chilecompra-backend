class SearchesController < ApplicationController
  include SearchesHelper
  before_action :authenticate_user!

  def show
    render json: show_searches
  end

  def create
    render json: create_search(search_params)
  end

  def update
  end

  def destroy
  end

  private

  def search_params
      params.require(:search).permit({:value => [
                                                :organismosPublicosFilter,
                                                :selectedOrganismoPublico,
                                                :codigoLicitacion,
                                                :date,
                                                :palabrasClave,
                                                :selectedEstadoLicitacion,
                                                :rutProveedor]}, 
                                                :name)

  end
end
