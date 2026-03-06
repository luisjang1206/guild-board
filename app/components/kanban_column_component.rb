# frozen_string_literal: true

class KanbanColumnComponent < ApplicationComponent
  def initialize(board_column:, tasks:)
    @board_column = board_column
    @tasks = tasks
  end

  private

  def task_count
    @tasks.size
  end

  def dom_id
    "board_column_#{@board_column.id}_tasks"
  end

  def project
    @board_column.project
  end
end
