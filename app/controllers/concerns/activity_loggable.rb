# frozen_string_literal: true

module ActivityLoggable
  extend ActiveSupport::Concern

  private

  def log_activity(action:, task: nil, metadata: {})
    ActivityLogJob.perform_later(
      project_id: @project.id,
      task_id: task&.id,
      actor_type: "user",
      actor_id: Current.user.id.to_s,
      action: action,
      metadata: metadata
    )
  end
end
