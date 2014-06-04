class Api::DrainsController < ApiController

  before_action :find_drain, only: [:show, :destroy]

  def create
    head 403
  end

  def index
    @drains = Drains.all
    render status: 200
  end

  def show
    render 'drain', status: 200
  end

  def update
    head 403
  end

  def destroy
    head 403
  end

  private def find_drain
    if drain = Drain.where(id: params[:id]).first
      @drain = drain
    else
      response = { id: "drain.not_exist",
                   message: "Drain (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

end