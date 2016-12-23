Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {registrations: 'registrations'}
  #mount Resque::Server, at: "/resque" #Mounts the sinatra app for the frontend

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/search', to: "requests#search"
  get '/test', to: "requests#testtwo"

  get '/get_misc_info', to: "requests#get_misc_info"
  get '/get_chilecompra_data', to: "requests#get_chilecompra_data"
  
  #post '/signup', to: 'users#create' #TBI
  #post '/signup', to: 'users#create'
  #get '/home', to: 'requests#show_hello'
 # get '/user_example', to: 'requests#return_example_user'
  #resources :users

end
