Dawn::Application.routes.draw do

  def subdomain name, options = {}
    options = {path: '/', constraints: {subdomain: name.to_s}}.merge!(options)
    namespace(name, options) { yield }
  end

  devise_for :users, :path => '/', :path_names => {:sign_in => 'login', :sign_out => 'logout', :sign_up => 'register'}

  subdomain :login do

  end

  # on root domain --> no subdomain
  constraints subdomain: '' do
    root to: 'home#index'
  end

  subdomain :dashboard do
    resources :apps, param: :name do # param maps to :name, not :id
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

    # TEST ROUTES
    get '/controls', to: 'apps#controls'
    get '/logs', to: 'apps#logs'
  end

  subdomain :docs do

  end

  subdomain :help do

  end

  # subdomain with a namespace under root --> api.dawn.io/apps --> Api::AppsController, not AppsController
  subdomain :api do
    resources :apps do
      # build, deploy, logs...
      member do
        resources :gears
        delete '/gears', to: 'gears#destroy_all'
        resources :domains
      end
    end

    post '/login', to: 'session#create'

    get '/q', to: 'keys#test'

    namespace :account do
      get '/', to: 'account#index'
      patch '/', to: 'account#update'
      resources :keys
    end
  end

  # catch git pushes locally
  post '/api/githook', to: 'stream#githook', :constraints => {:ip => /127.0.0.1/}

end