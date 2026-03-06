# frozen_string_literal: true

class CreateTaskTool < ApplicationTool
  description "새 태스크를 생성합니다"

  arguments do
    required(:title).filled(:string).description("태스크 제목")
    optional(:description).maybe(:string).description("태스크 설명")
    optional(:board_column_id).filled(:integer).description("칼럼 ID (미지정 시 첫 번째 칼럼)")
    optional(:priority).filled(:string).description("우선순위 (low/medium/high)")
  end

  def call(title:, description: nil, board_column_id: nil, priority: nil)
    column = if board_column_id
      Current.project.board_columns.find(board_column_id)
    else
      Current.project.board_columns.order(:position).first
    end

    task = Current.project.tasks.create!(
      title: title,
      description: description,
      board_column: column,
      priority: priority || :low,
      creator_type: "agent",
      creator_id: Current.agent_name
    )

    JSON.generate({
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      board_column: {
        id: column.id,
        name: column.name
      },
      created_at: task.created_at
    })
  end
end
