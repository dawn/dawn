class Api::GearsController < ApiController
  before_action :find_gear, only: [:show, :update, :restart, :destroy]

  def show
    render 'gear', status: 200
  end

  def update
    head 501
  end

  def restart
    @gear.restart
    head 200
  end

  def destroy
    head 501
  end

  private def find_gear
    if gear = Gear.where(id: params[:id]).first
      @gear = gear
    else
      response = { id: "gear.not_exist",
                   message: "Gear (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end
end
