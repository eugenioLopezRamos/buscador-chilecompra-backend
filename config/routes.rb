Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {registrations: 'registrations'}
  #mount Resque::Server, at: "/resque" #Mounts the sinatra app for the frontend


  #To be modified too, should get from cached request/db entry/whatever I decide, but not like it currently is
  get '/get_misc_info', to: "requests#get_misc_info"

  #This one fetches from the Chilecompra API. (Will not make it into prod, its unscalable. Will instead use the resque cronjobs + DB for this.)
 # get '/get_chilecompra_data', to: "requests#get_chilecompra_data"
 
  #this one gets results from the DB. Will replace get_chilecompra_data
  get '/get_info', to: "requests#get_info"


  #CRUD for user_results
  get '/results', to: "user_results#show"
  post '/results', to: "user_results#create"
  put '/results', to: "user_results#update"
  delete '/results', to: "user_results#destroy"

  #CRUD search queries
  get '/searches', to: "searches#show"
  post '/searches', to: "searches#create"
  put '/searches', to: "searches#update"
  delete '/searches', to: "searches#destroy"

end
