class ActivityLogJob < ApplicationJob
  queue_as :default

  def perform(project_id:, task_id: nil, actor_type:, actor_id:, action:, metadata: {})
    ActivityLog.create!(
      project_id: project_id,
      task_id: task_id,
      actor_type: actor_type,
      actor_id: actor_id,
      action: action,
      metadata: metadata
    )
  end
end
