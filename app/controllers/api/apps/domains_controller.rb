class Api::Apps::DomainsController < Api::AppsubController

  before_action :find_app, only: [:index, :show, :update, :destroy]
  before_action :find_domain, only: [:show, :update, :destroy]

  def create
    if !@app.domains.where(url: params[:url]).exists?
      @domain = @app.domains.create(app: @app, url: params[:url])
      if @domain.save
        render 'domain', status: 200
      else
        # :TODO: handle save error
        head 422
      end
    else
      response = { id: 'domain.exists',
                   message: "Domain #{params[:url]} exists" }
      render json: response, status: 409
    end
  end

  def index
    @domains = @app.domains
    render status: 200
  end

  def show
    render 'domain', status: 200
  end

  def update
    if @domain.update(url: params[:url])
      render 'domain', status: 200
    else
      # :TOOD: handle save error
      head 422
    end
  end

  def destroy
    if @domain.destroy
      head 200
    else
      # for some odd reason, it wouldn't destroy
      head 500
    end
  end

  private def find_domain
    if domain = @app.domains.where(id: params[:id]).first
      @domain = domain
    else
      response = { id: "domain.not_exist",
                   message: "Domain (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

end