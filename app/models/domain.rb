class Domain < ActiveRecord::Base

  validates :url, presence: true

  belongs_to :app

end
