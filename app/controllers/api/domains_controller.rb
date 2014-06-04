class Api::DomainsController < ApiController

  before_action :find_domain, only: [:show, :destroy]

  def create
    # creating a Domain outside of an App is forbidden (for now)
    head 403
  end

  def index
    @domains = Domain.all
    render status: 200
  end

  def show
    render 'domain', status: 200
  end

  def update
    # updating a Domain outside of an App is forbidden
    head 403
  end

  def destroy
    #@domain.destroy
    #head 200
    head 403
  end

  private def find_domain
    if domain = Domain.where(id: params[:id]).first
      @domain = domain
    else
      response = { id: "domain.not_exist",
                   message: "Domain (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

end