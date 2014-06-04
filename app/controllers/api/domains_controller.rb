class Api::DomainsController < Api::AppsubController

  before_action :find_app, only: [:index, :show, :destroy]

  def create
    domain = params[:name]
    if !@app.domains.include?(domain)
      @app.domains.push domain
      if @app.save
        @domain = domain
        render 'domain', status: 200
      else
        # handle error
        head 400
      end
    else
      head 409
    end
  end

  def index
    @domains = @app.domains
    render status: 200
  end

  def show
    render 'domain', status: 200
  end

  def destroy
    @app.domains.delete params[:name]
    if @app.save
      head 200
    else
      # handle error
      head 400
    end
  end

end