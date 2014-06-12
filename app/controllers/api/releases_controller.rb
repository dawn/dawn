class Api::ReleasesController < ApiController
  def show
    render 'release', status: 200
  end

  private def find_release
    if release = Release.where(id: params[:id]).first
      @release = release
    else
      response = { id: "release.not_exist",
                   message: "Release (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end
end
