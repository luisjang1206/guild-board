# frozen_string_literal: true

require "test_helper"

class UpdateTaskToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "updates task title" do
    tool = UpdateTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, title: "Updated Title"))

    assert_equal task.id, result["id"]
    assert_equal "Updated Title", result["title"]
    assert_equal "Updated Title", task.reload.title
  end

  test "updates task description" do
    tool = UpdateTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, description: "New description"))

    assert_equal "New description", result["description"]
    assert_equal "New description", task.reload.description
  end

  test "updates task priority" do
    tool = UpdateTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, priority: "high"))

    assert_equal "high", result["priority"]
    assert task.reload.high?
  end

  test "updates multiple fields simultaneously" do
    tool = UpdateTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(
      task_id: task.id,
      title: "Multi Update",
      description: "Updated desc",
      priority: "medium"
    ))

    assert_equal "Multi Update", result["title"]
    assert_equal "Updated desc", result["description"]
    assert_equal "medium", result["priority"]
  end

  test "result includes updated_at" do
    tool = UpdateTaskTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, title: "Time Check"))

    assert result.key?("updated_at")
  end

  test "returns error for non-existent task_id" do
    tool = UpdateTaskTool.new
    result = JSON.parse(tool.call(task_id: 0, title: "Fail"))

    assert result.key?("error")
    assert_match(/0/, result["error"])
  end

  test "returns error for soft-deleted task" do
    tool = UpdateTaskTool.new
    deleted = tasks(:deleted_task)

    result = JSON.parse(tool.call(task_id: deleted.id, title: "Should Fail"))

    assert result.key?("error"), "Soft-deleted task should not be updatable"
  end

  test "does not modify task when only task_id is provided" do
    tool = UpdateTaskTool.new
    task = tasks(:active_task)
    original_title = task.title
    original_description = task.description

    tool.call(task_id: task.id)

    task.reload
    assert_equal original_title, task.title
    assert_equal original_description, task.description
  end
end
