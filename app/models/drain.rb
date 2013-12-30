class Drain

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :app

  field :name, type: String # Should drains even have a name? eg. McSwirly
  field :url,  type: String # Where does this drain lead?

end