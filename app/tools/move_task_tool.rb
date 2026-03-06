# frozen_string_literal: true

class MoveTaskTool < ApplicationTool
  description "태스크를 다른 칼럼으로 이동합니다"

  arguments do
    required(:task_id).filled(:integer).description("태스크 ID")
    required(:board_column).filled(:string).description("이동할 칼럼 이름 또는 ID")
    optional(:position).filled(:integer).description("이동할 위치 (0부터 시작)")
  end

  def call(task_id:, board_column:, position: nil)
    task = Current.project.tasks.active.find_by(id: task_id)
    return JSON.generate({ error: "태스크를 찾을 수 없습니다 (id: #{task_id})" }) unless task

    target_column = find_column(board_column)
    return JSON.generate({ error: "칼럼을 찾을 수 없습니다 (#{board_column})" }) unless target_column

    old_column_name = task.board_column.name
    new_position = position || target_column.tasks.active.count
    task.move_to_column(target_column.id, new_position)

    ActivityLogJob.perform_later(
      project_id: Current.project.id,
      task_id: task.id,
      actor_type: "agent",
      actor_id: Current.agent_name,
      action: "task_moved",
      metadata: { board_column: [ old_column_name, target_column.name ] }
    )

    JSON.generate({
      id: task.id,
      title: task.title,
      board_column: {
        id: target_column.id,
        name: target_column.name
      },
      position: task.reload.position
    })
  end

  private

  def find_column(board_column)
    columns = Current.project.board_columns
    if board_column.match?(/\A\d+\z/)
      columns.find_by(id: board_column.to_i)
    else
      columns.find_by(name: board_column)
    end
  end
end
