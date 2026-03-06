class ProjectKey < ApplicationRecord
  belongs_to :project

  KEY_PREFIX = "guild_"
  KEY_PREFIX_LENGTH = 13

  validates :key_digest, :key_prefix, :name, presence: true
  validates :key_prefix, uniqueness: true, length: { is: KEY_PREFIX_LENGTH }
  validates :name, length: { maximum: 100 }

  scope :active, -> { where(active: true) }

  def self.generate_for(project, name:, permissions: {})
    raw_key = KEY_PREFIX + SecureRandom.base58(24)
    key_digest = BCrypt::Password.create(raw_key)
    key_prefix = raw_key[0, KEY_PREFIX_LENGTH]
    record = project.project_keys.create!(
      key_digest: key_digest,
      key_prefix: key_prefix,
      name: name,
      permissions: permissions
    )
    [ record, raw_key ]
  end

  def authenticate(raw_key)
    BCrypt::Password.new(key_digest) == raw_key
  rescue BCrypt::Errors::InvalidHash
    false
  end
end
