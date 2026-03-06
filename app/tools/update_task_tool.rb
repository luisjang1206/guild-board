# frozen_string_literal: true

class UpdateTaskTool < ApplicationTool
  description "태스크 정보를 수정합니다"

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

    JSON.generate({
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      updated_at: task.updated_at
    })
  end
end
