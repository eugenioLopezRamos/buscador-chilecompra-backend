class SearchesController < ApplicationController
    include SearchesHelper

    before_action :authenticate_user!
  #  before_action :valid_params?, only: [:create, :update, :destroy]

    def show
      
    end

    def create
      create_search(search_params)
    end

    def update
    end

    def destroy
    end

   private

    def search_params
        params.require(:searches).permit(:organismosPublicosFilter,
                                         :selectedOrganismoPublico,
                                         :codigoLicitacion,
                                         :date,
                                         :palabrasClave,
                                         :selectedEstadoLicitacion,
                                         :rutProveedor
                                         )
        params.permit(:searchName)
    end


end
