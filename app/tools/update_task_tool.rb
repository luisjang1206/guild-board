# frozen_string_literal: true

class UpdateTaskTool < ApplicationTool
  description "태스크의 제목, 설명, 우선순위를 수정합니다. " \
              "칼럼 이동은 이 도구로 할 수 없으며, move_task 도구를 사용하세요."

  arguments do
    required(:task_id).filled(:integer).description("태스크 ID")
    optional(:title).maybe(:string).description("새 제목")
    optional(:description).maybe(:string).description("새 설명")
    optional(:priority).maybe(:string).description("새 우선순위 (low/medium/high)")
  end

  def call(task_id:, title: nil, description: nil, priority: nil)
    task = Current.project.tasks.active.find_by(id: task_id)
    return JSON.generate({ error: "태스크를 찾을 수 없습니다 (id: #{task_id})" }) unless task

    attrs = {}
    attrs[:title] = title unless title.nil?
    attrs[:description] = description unless description.nil?
    attrs[:priority] = priority unless priority.nil?

    task.update!(attrs)

    ActivityLogJob.perform_later(
      project_id: Current.project.id,
      task_id: task.id,
      actor_type: "agent",
      actor_id: Current.agent_name,
      action: "task_updated",
      metadata: task.saved_changes.except("updated_at")
    )

    JSON.generate({
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      updated_at: task.updated_at
    })
  end
end
