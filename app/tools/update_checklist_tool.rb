# frozen_string_literal: true

class UpdateChecklistTool < ApplicationTool
  description "체크리스트 항목의 완료 상태를 변경합니다"

  arguments do
    required(:checklist_id).filled(:integer).description("체크리스트 ID")
    required(:completed).filled(:bool).description("완료 여부")
  end

  def call(checklist_id:, completed:)
    checklist = Checklist
      .joins(task: :project)
      .where(tasks: { project_id: Current.project.id })
      .find_by(id: checklist_id)

    return JSON.generate({ error: "체크리스트를 찾을 수 없습니다 (id: #{checklist_id})" }) unless checklist

    checklist.update!(completed: completed)

    ActivityLogJob.perform_later(
      project_id: Current.project.id,
      task_id: checklist.task_id,
      actor_type: "agent",
      actor_id: Current.agent_name,
      action: "checklist_toggled",
      metadata: { content: checklist.content, completed: checklist.completed }
    )

    JSON.generate({
      id: checklist.id,
      content: checklist.content,
      completed: checklist.completed,
      task_id: checklist.task_id
    })
  end
end
