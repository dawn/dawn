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

  def get_env
    render 'env', status: 200
  end

  def update_env
    if @app.update(env: params[:env])
      render 'env', status: 200
    else
      head 500
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
    opts = { }
    opts[:tail] = true if params[:tail]
    opts[:num]  = params[:num] if params.key?(:num)
    @logs = @app.logs(opts)
    render status: 200
  end

  # starts a one-off container session
  def run
    head 400 unless params[:command]

    if env['rack.hijack']
      env['rack.hijack'].call

      socket = env['rack.hijack_io']
      begin
        socket.write("hello!\n")
        socket.flush
        socket.sync = true
        socket.write("docker run  -i -t -rm #{@app.releases.last.image} #{params[:command]}\n")
        socket.write("params: #{params}\n")
        docker = "docker run  -i -t -rm #{@app.releases.last.image} #{params[:command]}"
        pid = Process.spawn({}, docker, {in: socket, out: socket, err: socket})
        Process.wait(pid)
      ensure
        socket.close
      end
    end
  end

  private def find_app
    if app = App.where(id: params[:id]).first
      @app = app
    else
      head 404
    end
  end

  private def verify_app_owner
    unless @app.user == current_user
      head 401
    end
  end

end