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
    @app = App.new(params[:app].permit[:name])
    @app.user = current_user

    if @app.save
      redirect_to @app, notice: 'app was successfully created.'
    else
      render action: "new"
    end
  end

  # -- per app pages

  def controls

  end

  def logs

  end
end
