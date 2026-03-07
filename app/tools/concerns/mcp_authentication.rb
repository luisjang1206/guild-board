# frozen_string_literal: true

module McpAuthentication
  extend ActiveSupport::Concern

  included do
    authorize do
      authenticate_project_key!
    end
  end

  private

  def authenticate_project_key!
    raw_key = extract_header("X-Project-Key")
    return false if raw_key.blank?
    return false if raw_key.length < ProjectKey::KEY_PREFIX_LENGTH

    prefix = raw_key[0, ProjectKey::KEY_PREFIX_LENGTH]
    project_key = ProjectKey.active.find_by(key_prefix: prefix)
    return false unless project_key&.authenticate(raw_key)

    Current.project = project_key.project
    Current.agent_name = extract_header("X-Agent-Name").presence || "unknown-agent"

    return false unless rate_limit_ok?(prefix)

    touch_last_used_at(project_key)
    true
  end

  def rate_limit_ok?(key_prefix)
    cache_key = "mcp_rate:#{key_prefix}"
    count = Rails.cache.increment(cache_key, 1, expires_in: 1.minute)
    if count.nil?
      Rails.cache.write(cache_key, 1, expires_in: 1.minute)
      count = 1
    end
    count <= 60
  end

  def extract_header(name)
    rack_key = "HTTP_#{name.upcase.tr('-', '_')}"
    headers[name] || headers[rack_key] || headers[name.upcase.tr("-", "_")] || headers[name.downcase]
  end

  def touch_last_used_at(project_key)
    return if project_key.last_used_at.present? && project_key.last_used_at > 5.minutes.ago

    project_key.update_column(:last_used_at, Time.current)
  end
end
