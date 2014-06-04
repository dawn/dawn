class Api::DrainsController < ApiController
  before_action :find_drain, only: [:show, :update, :destroy]

  def show
    render 'drain', status: 200
  end

  def update
    head 501
  end

  def destroy
    @drain.destroy
    head 200
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
