class Api::DomainsController < ApiController
  before_action :find_domain, only: [:show, :update, :destroy]

  def show
    render 'domain', status: 200
  end

  def update
    head 501
  end

  def destroy
    @domain.destroy
    head 200
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
