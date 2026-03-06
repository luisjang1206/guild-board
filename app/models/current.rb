class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :project
  attribute :agent_name
  delegate :user, to: :session, allow_nil: true
end
