Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {registrations: 'registrations'}
  #mount Resque::Server, at: "/resque" #Mounts the sinatra app for the frontend


  #To be modified too, should get from cached request/db entry/whatever I decide, but not like it currently is
  get '/get_misc_info', to: "requests#get_misc_info"

  #This one fetches from the Chilecompra API. (Will not make it into prod, its unscalable. Will instead use the resque cronjobs + DB for this.)
 # get '/get_chilecompra_data', to: "requests#get_chilecompra_data"
 
  #this one gets results from the DB. Will replace get_chilecompra_data
  #TODO: bad name, too general. change here and in frontend
  get '/get_info', to: "requests#get_info"


  #CRUD for user_results
  #TODO: resources: user_results, or however it's done.
  #Tambien se puede cambiar a algo como /results => requests#get_info (reemplazando el requests controller)
  # y luego /results/user, to: user_results#show para hacerlo mas consistente

 # get '/results', to: redirect('/results/subscriptions')
  post '/results', to: "user_results#create_stored_result"
  put '/results', to: "user_results#update"
  delete '/results', to: "user_results#destroy"
    #subscriptions
  get '/results/subscriptions', to: "user_results#show" #Get all results that a user is subscribed to
  post '/results/subscriptions', to: "user_results#create" #Create a new one
  put '/results/subscriptions', to: "user_results#update" #Modify
  delete '/results/subscriptions', to: "user_results#destroy"


  #A bit of a special case, so I'll leave it near /results
  #TODO: change this route...
  get '/user_results', to: "user_results#show_stored_results_values"


  #CRUD search queries
  get '/searches', to: "searches#show"
  post '/searches', to: "searches#create"
  put '/searches', to: "searches#update"
  delete '/searches', to: "searches#destroy"

end
