Dawn::Application.routes.draw do
  resources :gears, except: [:index, :create] do
    member do
      post '/restart', to: 'gears#restart'
    end
  end

  resources :domains,  except: [:index, :create]
  resources :drains,   except: [:index, :create]
  get '/releases/:id', to: "releases#show"

  resources :apps do
    member do
      post '/gears',         to: 'apps#create_gear'
      post '/domains',       to: 'apps#create_domain'
      post '/drains',        to: 'apps#create_drain'
      post '/releases',      to: 'apps#create_release'
      get '/gears',          to: 'apps#gears'
      get '/domains',        to: 'apps#domains'
      get '/drains',         to: 'apps#drains'
      get '/releases',       to: 'apps#releases'
      post '/gears/restart', to: 'apps#gears_restart'

      get '/scale',          to: 'apps#formation'
      put '/scale',          to: 'apps#scale'
      post '/scale',         to: 'apps#scale'

      get '/env',            to: 'apps#get_env'
      put '/env',            to: 'apps#update_env'
      post '/env',           to: 'apps#update_env'

      get '/logs',           to: 'apps#logs'

      post '/run',           to: 'apps#run'
    end
  end

  post '/login', to: 'session#create'

  namespace :account do
    get '/',   to: 'account#index'
    patch '/', to: 'account#update'
    resources :keys
  end

  get '/healthcheck',  to: 'healthcheck#index'

  get '/git/api_key',  to: 'git/git#api_key'
  get '/git/allowed',  to: 'git/git#allowed'
end
