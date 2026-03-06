# frozen_string_literal: true

class GetTaskTool < ApplicationTool
  description "태스크의 상세 정보를 조회합니다"

  arguments do
    required(:task_id).filled(:integer).description("조회할 태스크 ID")
  end

  def call(task_id:)
    task = Current.project.tasks.active
      .includes(:labels, :checklists, :comments, :board_column)
      .find_by(id: task_id)

    return JSON.generate({ error: "Task not found (id: #{task_id})" }) if task.nil?

    result = {
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      position: task.position,
      creator_type: task.creator_type,
      creator_id: task.creator_id,
      board_column: {
        id: task.board_column.id,
        name: task.board_column.name
      },
      labels: task.labels.map { |l| { id: l.id, name: l.name, color: l.color } },
      checklists: task.checklists.order(:position).map do |c|
        { id: c.id, content: c.content, completed: c.completed, position: c.position }
      end,
      comments: task.comments.order(:created_at).map do |c|
        { id: c.id, content: c.content, author_type: c.author_type, author_id: c.author_id, created_at: c.created_at }
      end,
      created_at: task.created_at,
      updated_at: task.updated_at
    }

    JSON.generate(result)
  end
end
