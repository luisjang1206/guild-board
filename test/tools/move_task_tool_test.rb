# frozen_string_literal: true

require "test_helper"

class MoveTaskToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "moves task by column name" do
    tool = MoveTaskTool.new
    task = tasks(:active_task)
    target = board_columns(:in_progress)

    result = JSON.parse(tool.call(task_id: task.id, board_column: "In Progress"))

    assert_equal task.id, result["id"]
    assert_equal target.id, result["board_column"]["id"]
    assert_equal "In Progress", result["board_column"]["name"]
    assert_equal target.id, task.reload.board_column_id
  end

  test "moves task by column id as string" do
    tool = MoveTaskTool.new
    task = tasks(:active_task)
    target = board_columns(:review)

    result = JSON.parse(tool.call(task_id: task.id, board_column: target.id.to_s))

    assert_equal target.id, result["board_column"]["id"]
    assert_equal "Review", result["board_column"]["name"]
  end

  test "moves task to specified position" do
    tool = MoveTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, board_column: "In Progress", position: 0))

    assert_equal 0, result["position"]
    assert_equal 0, task.reload.position
  end

  test "returns error for non-existent task_id" do
    tool = MoveTaskTool.new
    result = JSON.parse(tool.call(task_id: 0, board_column: "Backlog"))

    assert result.key?("error")
    assert_match(/0/, result["error"])
  end

  test "returns error for non-existent column name" do
    tool = MoveTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, board_column: "NonExistentColumn"))

    assert result.key?("error")
    assert_match(/NonExistentColumn/, result["error"])
  end

  test "returns error when column id does not exist in project" do
    tool = MoveTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, board_column: "99999999"))

    assert result.key?("error")
  end

  test "result includes id, title, board_column, position" do
    tool = MoveTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, board_column: "Done"))

    assert result.key?("id")
    assert result.key?("title")
    assert result.key?("board_column")
    assert result.key?("position")
  end
end
