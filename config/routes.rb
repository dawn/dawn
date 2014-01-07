Dawn::Application.routes.draw do

  def subdomain name, options = {}
    options = {path: '/', constraints: {subdomain: name.to_s}}.merge!(options)
    namespace(name, options) { yield }
  end

  subdomain :login do

  end

  # on root domain --> no subdomain
  constraints subdomain: '' do
    root to: 'home#index'
  end

  subdomain :dashboard do
    resources :apps, param: :name, except: [:show] do # param maps to :name, not :id
      member do
        get 'controls'
        get 'metrics'
        get 'services'
        get 'environment'
        get 'domains'
        get 'ssl'
        get 'logs'
        get 'settings'
      end
    end

    get '/', to: redirect('/apps')
    # get '/settings' ?
  end

  subdomain :docs do

  end

  subdomain :help do

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

  namespace :git do
    post '/api/git/hook',    to: 'api/git/stream#hook', constraints: { ip: /127.0.0.1/ }
    post '/api/git/allowed', to: 'api/git/git#allowed', constraints: { ip: /127.0.0.1/ }
  end
  # catch git pushes locally

  devise_for :users, :path => '/', :path_names => {:sign_in => 'login', :sign_out => 'logout', :sign_up => 'register'}

end