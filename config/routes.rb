Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/search', to: "requests#search"
  get '/test', to: "requests#testtwo"

  get '/get_misc_info', to: "requests#get_misc_info"
  get '/get_info', to: "requests#get_chilecompra_data"



end
