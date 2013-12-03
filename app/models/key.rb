class Key # SSH public key representation
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create do # add the key to authorized_keys
    Dir.chdir Dir.home("git") do
      File.open('.ssh/authorized_keys', 'a') { |io| io.write key }
    end
  end

  before_destroy do # remove the key from authorized_keys (HAXX)
    Dir.chdir Dir.home("git") do
      File.open('.ssh/authorized_keys', 'a') do |io|
        contents = io.read.sub(key, '')
        io.write contents
      end
    end
  end

  field :key, type: String
  field :fingerprint, type: String

  belongs_to :user
end
