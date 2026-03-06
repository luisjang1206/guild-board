# frozen_string_literal: true

require "test_helper"

class ListTasksToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "returns only active tasks without filters" do
    tool = ListTasksTool.new
    result = JSON.parse(tool.call)

    titles = result.map { |t| t["title"] }
    assert_includes titles, "Active Task"
    assert_not_includes titles, "Deleted Task"
  end

  test "result items include required keys" do
    tool = ListTasksTool.new
    result = JSON.parse(tool.call)

    result.each do |task|
      %w[id title priority position board_column labels checklist_progress].each do |key|
        assert task.key?(key), "Expected '#{key}' key in task hash"
      end
    end
  end

  test "filters by board_column_id" do
    tool = ListTasksTool.new
    todo_id = board_columns(:todo).id
    result = JSON.parse(tool.call(board_column_id: todo_id))

    assert result.all? { |t| t["board_column"]["id"] == todo_id },
      "All tasks should belong to the todo column"
    assert_equal 1, result.size
    assert_equal "Active Task", result.first["title"]
  end

  test "filters by priority" do
    tool = ListTasksTool.new
    # active_task는 priority=0 (low), fixture에서 user_one_project에 low priority active task만 존재
    result = JSON.parse(tool.call(priority: "low"))

    assert result.all? { |t| t["priority"] == "low" },
      "All returned tasks should have low priority"
    assert result.any?
  end

  test "returns no tasks when priority filter matches nothing" do
    tool = ListTasksTool.new
    # user_one_project의 active 태스크는 active_task(low)뿐이므로 high는 없다
    result = JSON.parse(tool.call(priority: "high"))

    assert_equal [], result
  end

  test "filters by label_id" do
    tool = ListTasksTool.new
    frontend_id = labels(:frontend).id
    result = JSON.parse(tool.call(label_id: frontend_id))

    # active_task_frontend fixture로 active_task에 frontend 라벨이 붙어 있다
    assert_equal 1, result.size
    assert_equal "Active Task", result.first["title"]
    label_ids = result.first["labels"].map { |l| l["id"] }
    assert_includes label_ids, frontend_id
  end

  test "checklist_progress reflects done/total counts" do
    tool = ListTasksTool.new
    result = JSON.parse(tool.call)

    active = result.find { |t| t["title"] == "Active Task" }
    assert_not_nil active
    # task_checklist_1(completed=false), task_checklist_2(completed=true) → "1/2"
    assert_equal "1/2", active["checklist_progress"]
  end

  test "returns tasks in position order" do
    tool = ListTasksTool.new
    result = JSON.parse(tool.call)

    positions = result.map { |t| t["position"] }
    assert_equal positions.sort, positions
  end
end
