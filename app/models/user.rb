class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, format: { with: RFC822::EMAIL_REGEXP_WHOLE }, uniqueness: true

  # validates_uniqueness_of :username, :reset_password_token

  # TODO: validate min password length

  before_create :ensure_api_key
  def ensure_api_key
    self.api_key = generate_api_key if api_key.blank?
  end

  private def generate_api_key
    loop do
      key = Devise.friendly_token
      break key unless User.where(api_key: key).exists?
    end
  end

  has_many :apps
  has_many :keys

end