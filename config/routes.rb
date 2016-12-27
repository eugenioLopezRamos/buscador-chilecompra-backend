Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {registrations: 'registrations'}
  #mount Resque::Server, at: "/resque" #Mounts the sinatra app for the frontend

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #To be modified too, should get from cached request/db entry/whatever I decide, but not like it currently is
  get '/get_misc_info', to: "requests#get_misc_info"

  #This one fetches from the Chilecompra API. (Will not make it into prod, its unscalable. Will instead use the resque cronjobs + DB for this.)
 # get '/get_chilecompra_data', to: "requests#get_chilecompra_data"



  #this one results from the DB. Will replace get_chilecompra_data
  get '/get_info', to: "requests#get_info"
  
  #post '/signup', to: 'users#create' #TBI
  #post '/signup', to: 'users#create'
  #get '/home', to: 'requests#show_hello'
 # get '/user_example', to: 'requests#return_example_user'
  #resources :users

end
