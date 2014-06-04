class Api::AccountController < ApiController

  before_action :find_account, only: [:index, :update]

  def index
    render 'account'
  end

  def update
    if @account.update(account_params)
      render status: 200
    else
      render status: 422 # 422 could work too
    end
  end

  private def find_account
    @account = current_user
  end

  private def account_params
    params.require(:account).permit(:username, :password)
  end

end