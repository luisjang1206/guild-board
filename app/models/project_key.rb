class ProjectKey < ApplicationRecord
  belongs_to :project

  validates :key_digest, :key_prefix, :name, presence: true

  scope :active, -> { where(active: true) }

  KEY_PREFIX = "guild_"

  def self.generate_for(project, name:, permissions: {})
    raw_key = KEY_PREFIX + SecureRandom.base58(24)
    key_digest = BCrypt::Password.create(raw_key)
    key_prefix = raw_key[0, 13]
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
