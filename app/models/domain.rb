class Domain < ActiveRecord::Base

  validates :url, presence: true, uniqueness: true

  belongs_to :app

end
