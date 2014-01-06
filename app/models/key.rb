class Key # SSH public key representation

  include Mongoid::Document
  include Mongoid::Timestamps

  field :key,         type: String
  field :fingerprint, type: String

  def gitlab_keys(arg)
    system("/opt/gitlab-shell/bin/gitlab-keys #{arg}")
  end
  private :gitlab_keys

  after_create do
    gitlab_keys("add-key #{id} \"#{key}\"")
  end

  before_destroy do
    gitlab_keys("rm-key \"#{id}\"")
  end

  belongs_to :user

end