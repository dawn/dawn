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
    resources :gears do
      member do
        post '/restart', to: 'gears#restart'
      end
    end
    #post '/gears/restart', to: 'apps/gears#restart_all' # admin only
    resources :domains
    resources :drains

    resources :apps do
      resources :gears,   to: "apps/gears" do
        post '/restart', to: 'apps/gears#restart'
      end
      post '/gears/restart', to: 'apps/gears#restart_all'
      resources :domains, to: "apps/domains"
      resources :drains,  to: "apps/drains"

      member do

        #get '/gears',    to: 'apps#get_gears'   #
        #get '/domains',  to: 'apps#get_domains' #
        #get '/drains',   to: 'apps#get_drains'  #

        get '/scale',    to: 'apps#formation'
        put '/scale',    to: 'apps#scale'
        post '/scale',   to: 'apps#scale'

        get '/env',      to: 'apps#get_env'
        put '/env',      to: 'apps#update_env'
        post '/env',     to: 'apps#update_env'

        get '/logs',     to: 'apps#logs'

        post '/run',     to: 'apps#run'
      end
    end

    post '/login', to: 'session#create'

    namespace :account do
      get '/',   to: 'account#index'
      patch '/', to: 'account#update'
      resources :keys
    end
  end

  post '/api/git/hook',    to: 'api/git/stream#hook',  constraints: { ip: /127.0.0.1/ }
  get '/api/git/allowed',  to: 'api/git/git#allowed',  constraints: { ip: /127.0.0.1/ }
  get '/api/git/discover', to: 'api/git/git#discover', constraints: { ip: /127.0.0.1/ }
  # catch git pushes locally

end