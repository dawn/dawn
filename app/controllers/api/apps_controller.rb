require 'fileutils'

class Api::AppsController < ApiController

  def index
    @apps = current_user.apps
    render
  end

  def create
    App.create!(name: params[:name], user: current_user)
  end

end
