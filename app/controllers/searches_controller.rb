class SearchesController < ApplicationController
    before_action :authenticate_user!

    def show
       
    end

    def create
         puts "this is searches create, params #{params}"
    end

    def update
    end

    def destroy
    end

   


end
