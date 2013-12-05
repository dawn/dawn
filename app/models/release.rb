class Release
  include Mongoid::Document
  include Mongoid::Timestamps

  # if a new release was added, redeploy (destroy all gears and recreate)
  #after_create do # replace with after_add in app?
    #app.deploy!
  #end

  validates_presence_of :image, :version

  # the docker image name of the release (typically <user>/<app>:v<number>)
  field :image, type: String
  field :version, type: Integer

  belongs_to :app
end
