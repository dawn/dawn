class Dashboard::AppsController < ApplicationController
  before_action :authenticate_user!
  layout 'app'

  def index
    @apps = current_user.apps
    render layout: 'dashboard'
  end

  def new
    @app = App.new
    render layout: 'dashboard'
  end

  def create
    @app = App.new(name: params[:app][:name])
    @app.user = current_user

    if @app.save
      redirect_to [:dashboard, @app], notice: 'app was successfully created.'
    else
      render action: 'new', layout: 'dashboard'
    end
  end

  # -- per app pages

  def controls
    @app = App.find_by(name: params[:app][:name])
  end

  def logs
    @app = App.find_by(name: params[:app][:name])
  end
end
