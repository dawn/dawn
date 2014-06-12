Dawn::Application.routes.draw do

  def subdomain name, options = {}
    options = { path: '/', constraints: { subdomain: name.to_s } }.deep_merge(options)
    namespace(name, options) { yield }
  end

  subdomain :login do

  end

  # on root domain --> no subdomain
  constraints subdomain: '' do
    root to: 'home#index'
  end

  # subdomain with a namespace under root -->
  #   api.dawn.io/apps -->
  #   Api::AppsController, not AppsController
  subdomain :api do
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
  end

  get '/api/git/api_key',  to: 'api/git/git#api_key',  constraints: { ip: /127.0.0.1/ }
  get '/api/git/allowed',  to: 'api/git/git#allowed',  constraints: { ip: /127.0.0.1/ }
  get '/api/git/discover', to: 'api/git/git#discover', constraints: { ip: /127.0.0.1/ }
  # catch git pushes locally

end
