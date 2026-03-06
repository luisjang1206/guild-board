require "test_helper"

class KanbanColumnComponentTest < ViewComponent::TestCase
  setup do
    @board_column = board_columns(:todo)
    @active_task = tasks(:active_task)
  end

  test "renders column name" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: []))
    assert_text(@board_column.name)
  end

  test "renders task count as zero when no tasks" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: []))
    assert_selector("span", text: "0")
  end

  test "renders task count matching number of tasks" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: [ @active_task, @active_task ]))
    assert_selector("span", text: "2")
  end

  test "renders task list container with correct dom id" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: []))
    assert_selector("div#board_column_#{@board_column.id}_tasks")
  end

  test "renders empty state message when no tasks" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: []))
    assert_text(I18n.t("board_column.no_tasks"))
  end

  test "renders task card with task title when tasks present" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: [ @active_task ]))
    assert_text(@active_task.title)
  end

  test "does not render empty state message when tasks present" do
    render_inline(KanbanColumnComponent.new(board_column: @board_column, tasks: [ @active_task ]))
    assert_no_text("No tasks yet")
  end
end
