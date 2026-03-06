# frozen_string_literal: true

class ListColumnsTool < ApplicationTool
  description "현재 프로젝트의 보드 칼럼 목록을 조회합니다"

  def call
    columns = Current.project.board_columns.order(:position)

    result = columns.map do |column|
      tasks_count = column.tasks.where(deleted_at: nil).count

      {
        id: column.id,
        name: column.name,
        position: column.position,
        tasks_count: tasks_count
      }
    end

    JSON.generate(result)
  end
end
