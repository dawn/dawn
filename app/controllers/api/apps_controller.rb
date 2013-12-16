class Api::AppsController < ApiController

  actions = [:index, :create]
  before_action :find_app, except: actions
  before_action :verify_app_owner, except: actions

  def index
    if name = params[:name]
      @apps = current_user.apps.where(name: name)
    else
      @apps = current_user.apps
    end
    render status: 200
  end

  def create
    appname = params[:name]
    if App.where(name: appname).first
      head 409
    else
      @app = App.new(name: appname, user: current_user)
      if @app.save
        render 'app', status: 200
      else
        head 500
      end
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

  def formation
    render status: 200
  end

  def scale
    @app.scale(params[:formation])
    head 200
  end

  def logs
    render json: @app.logs(params.permit(:num, :tail)), status: 200
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