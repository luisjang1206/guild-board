# frozen_string_literal: true

class ListTasksTool < ApplicationTool
  description "프로젝트의 태스크 목록을 조회합니다"

  arguments do
    optional(:board_column_id).filled(:integer).description("칼럼 ID로 필터링")
    optional(:priority).filled(:string).description("우선순위 필터 (low/medium/high)")
    optional(:label_id).filled(:integer).description("라벨 ID로 필터링")
  end

  def call(board_column_id: nil, priority: nil, label_id: nil)
    tasks = Current.project.tasks.active
    tasks = tasks.where(board_column_id: board_column_id) if board_column_id
    tasks = tasks.where(priority: priority) if priority
    tasks = tasks.joins(:labels).where(labels: { id: label_id }) if label_id
    tasks = tasks.includes(:board_column, :labels, :checklists).order(:position)

    result = tasks.map do |task|
      total = task.checklists.size
      done  = task.checklists.count(&:completed)

      {
        id: task.id,
        title: task.title,
        priority: task.priority,
        position: task.position,
        board_column: {
          id: task.board_column.id,
          name: task.board_column.name
        },
        labels: task.labels.map { |l| { id: l.id, name: l.name, color: l.color } },
        checklist_progress: "#{done}/#{total}"
      }
    end

    JSON.generate(result)
  end
end
