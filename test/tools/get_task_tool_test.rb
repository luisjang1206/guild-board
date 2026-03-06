# frozen_string_literal: true

require "test_helper"

class GetTaskToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "returns detailed task info for a valid task_id" do
    tool = GetTaskTool.new
    task = tasks(:active_task)
    result = JSON.parse(tool.call(task_id: task.id))

    assert_equal task.id, result["id"]
    assert_equal "Active Task", result["title"]
    assert_equal "An active test task", result["description"]
    assert_equal "low", result["priority"]
    assert result.key?("board_column")
    assert result.key?("labels")
    assert result.key?("checklists")
    assert result.key?("comments")
    assert result.key?("created_at")
    assert result.key?("updated_at")
  end

  test "returned task includes labels" do
    tool = GetTaskTool.new
    task = tasks(:active_task)
    result = JSON.parse(tool.call(task_id: task.id))

    label_names = result["labels"].map { |l| l["name"] }
    assert_includes label_names, "Frontend"
  end

  test "returned task includes checklists in position order" do
    tool = GetTaskTool.new
    task = tasks(:active_task)
    result = JSON.parse(tool.call(task_id: task.id))

    assert_equal 2, result["checklists"].size
    contents = result["checklists"].map { |c| c["content"] }
    assert_includes contents, "Write unit tests"
    assert_includes contents, "Update documentation"

    positions = result["checklists"].map { |c| c["position"] }
    assert_equal positions.sort, positions
  end

  test "returned task includes comments" do
    tool = GetTaskTool.new
    task = tasks(:active_task)
    result = JSON.parse(tool.call(task_id: task.id))

    assert_equal 2, result["comments"].size
    author_types = result["comments"].map { |c| c["author_type"] }
    assert_includes author_types, "user"
    assert_includes author_types, "agent"
  end

  test "returns error for non-existent task_id" do
    tool = GetTaskTool.new
    result = JSON.parse(tool.call(task_id: 0))

    assert result.key?("error")
    assert_match(/0/, result["error"])
  end

  test "returns error for soft-deleted task" do
    tool = GetTaskTool.new
    deleted = tasks(:deleted_task)
    result = JSON.parse(tool.call(task_id: deleted.id))

    assert result.key?("error"), "Soft-deleted task should not be found"
  end

  test "returns error for task belonging to a different project" do
    tool = GetTaskTool.new
    other_task = tasks(:high_priority_task)
    result = JSON.parse(tool.call(task_id: other_task.id))

    assert result.key?("error"), "Task from another project should not be accessible"
  end
end
