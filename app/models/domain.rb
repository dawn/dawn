class Domain

  validates :url, presence: true

  belongs_to :app

end