require 'sshkey'

# SSH public key representation
class SSHKeyValidator < ActiveModel::Validator
  def validate(record)
    unless SSHKey.valid_ssh_public_key?(record.key)
      record.errors[:key] << "is not a valid ssh public key"
    end
  end
end

class Key < ActiveRecord::Base
  before_validation(on: :create) do
    generate_fingerprint
  end

  validates_with SSHKeyValidator
  validates :key, presence: true
  validates :fingerprint, uniqueness: true, presence: true

  belongs_to :user

  def generate_fingerprint
    self.fingerprint = SSHKey.fingerprint(key)
  rescue SSHKey::PublicKeyError
  end
end
