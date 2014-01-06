class Key # SSH public key representation

  include Mongoid::Document
  include Mongoid::Timestamps

  field :key,         type: String
  field :fingerprint, type: String

  def gitlab_keys(arg)
    system("/opt/gitlab-shell/bin/gitlab-keys #{arg}")
  end
  private :gitlab_keys

  after_create do # add the key to authorized_keys
    gitlab_keys("add-key #{key}")
  end

  before_destroy do # remove the key from authorized_keys (HAXX)
    gitlab_keys("rm-key #{key}")
  end

  belongs_to :user

end