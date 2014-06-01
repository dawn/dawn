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

  # subdomain with a namespace under root --> api.dawn.io/apps --> Api::AppsController, not AppsController
  subdomain :api do
    resources :apps do
      # build, deploy, logs...
      resources :gears
      resources :domains
      resources :drains
      delete '/gears', to: 'gears#destroy_all'
      member do
        get '/scale',    to: 'apps#formation'
        post '/scale',   to: 'apps#scale'

        get '/env',      to: 'apps#get_env'
        put '/env',      to: 'apps#update_env'

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