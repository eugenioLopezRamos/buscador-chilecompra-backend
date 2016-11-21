Rails.application.routes.draw do
  devise_for :users
  #devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/search', to: "requests#search"
  get '/test', to: "requests#testtwo"

  get '/get_misc_info', to: "requests#get_misc_info"
  get '/get_info', to: "requests#get_chilecompra_data"


  post '/auth_user', to: 'authentication#authenticate_user'
  get '/home', to: 'requests#show_hello'

end
