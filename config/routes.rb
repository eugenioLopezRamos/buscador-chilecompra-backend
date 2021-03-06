Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: { registrations: 'registrations',
                                                                 sessions: 'sessions',
                                                                 token_validations: 'token_validations' }
  # mount Resque::Server, at: "/resque" #Mounts the sinatra app for the frontend

  # To be modified too, should get from cached request/db entry/whatever I decide, but not like it currently is
  get '/chilecompra_misc_data', to: 'requests#chilecompra_misc_data'

  # This one fetches from the Chilecompra API. (Will not make it into prod, its unscalable. Will instead use the resque cronjobs + DB for this.)
  # get '/get_chilecompra_data', to: "requests#get_chilecompra_data"

  # this one gets results from the DB. Will replace get_chilecompra_data
  # TODO: bad name, too general. change here and in frontend
  post '/licitacion_data', to: 'requests#licitacion_data'

  #  Gets all of a user's related data (his/her user info, searches,
  # notifications and stored results)
  get '/user', to: 'users#all_related_data'

  # detail for a certain result.
  get '/results/history', to: 'user_results#show_history' # get all the results with a certain CodigoExterno
  # subscriptions
  get '/results/subscriptions', to: 'user_results#show' # Get all results that a user is subscribed to
  post '/results/subscriptions', to: 'user_results#create' # Create a new one
  put '/results/subscriptions', to: 'user_results#update' # Modify
  delete '/results/subscriptions', to: 'user_results#destroy'

  # A bit of a special case, so I'll leave it near /results
  # TODO: change this route...
  # get '/user_results', to: "user_results#show_stored_results_values"

  # CRUD search queries
  get '/searches', to: 'searches#show'
  post '/searches', to: 'searches#create'
  put '/searches', to: 'searches#update'
  delete '/searches', to: 'searches#destroy'

  # CRUD notifications
  get '/notifications', to: 'notifications#show'
  delete '/notifications', to: 'notifications#destroy'
end
