class Api::AppsController < ApiController

  before_action :find_app, only: [:show, :update, :destroy]
  before_action :verify_app_owner, only: [:show, :update, :destroy]

  def index
    @apps = current_user.apps
    render
  end

  def create
    @app = App.new(name: params[:name], user: current_user)
    if @app.save
      render 'app', status: 200
    else
      render nothing: true, status: 500
    end
  end

  def show
    render 'app'
  end

  def update
    if @app.update(name: params[:name])
      render 'app', status: 200
    else
      render nothing: true, status: 500 # 422 could work too
    end
  end

  def destroy
    @app.destroy
    render nothing: true, status: 204
  end

  def find_app
    if app = App.find(params[:id])
      @app = app
    else
      render nothing: true, status: 404
    end
  end
  private :find_app

  def verify_app_owner
    unless @app.user == current_user
      render nothing: true, status: 401
    end
  end
  private :verify_app_owner

end