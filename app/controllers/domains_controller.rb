class DomainsController < ApiController
  before_action :find_domain, only: [:show, :update, :destroy]

  def show
    render 'domain', status: 200
  end

  def update
    head 501
  end

  def destroy
    if @domain.destroy
      response = { message: "domain has been destroyed" }
      render json: response, status: 200
    else
      head 500
    end
  end

  private def find_domain
    domain = Domain.where(id: params[:id]).first
    domain = Domain.where(url: params[:id]).first unless domain
    if domain
      @domain = domain
    else
      response = { id: "domain.not_exist",
                   message: "Domain (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end
end
