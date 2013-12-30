class Drain

  ## mixins
  include Mongoid::Document
  include Mongoid::Timestamps

  ## ownership
  belongs_to :app

  ## attributes
  field :name, type: String # Should drains even have a name? eg. McSwirly
  field :url,  type: String # Where does this drain lead?

  ## validation
  validates :url, #uniqueness: true,
                  presence: true
  ## validation-callback
  before_validation :ensure_name, unless: Proc.new { |model| model.persisted? }

  def ensure_name
    if name.blank?
      loop do
        self.name = Forgery(:dawn).drain_name
        break name if valid?
      end
    end
  end

end