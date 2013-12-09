class Api::AppsController < ApiController

  before_action :find_app, only: [:show, :update, :destroy]
  before_action :verify_app_owner, only: [:show, :update, :destroy]

  def index
    @apps = current_user.apps
    render status: 200
  end

  def create
    @app = App.new(name: params[:name], user: current_user)
    if @app.save
      render 'app', status: 200
    else
      head 500
    end
  end

  def show
    render 'app'
  end

  def update
    if @app.update(name: params[:name])
      render 'app', status: 200
    else
      head 500 # 422 could work too
    end
  end

  def destroy
    @app.destroy
    head 204
  end

  def find_app
    if app = App.where(id: params[:id]).first
      @app = app
    else
      head 404
    end
  end
  private :find_app

  def verify_app_owner
    unless @app.user == current_user
      head 401
    end
  end
  private :verify_app_owner

end