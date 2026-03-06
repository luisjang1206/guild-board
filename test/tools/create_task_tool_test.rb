# frozen_string_literal: true

require "test_helper"

class CreateTaskToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "creates a task with only title provided" do
    tool = CreateTaskTool.new

    assert_difference "Task.count", 1 do
      @result = JSON.parse(tool.call(title: "My New Task"))
    end

    assert_equal "My New Task", @result["title"]
    assert_nil @result["description"]
    # 명시적 board_column_id 없으면 첫 번째 칼럼(position 0 = Backlog)에 생성
    assert_equal "Backlog", @result["board_column"]["name"]
    assert @result.key?("id")
    assert @result.key?("created_at")
  end

  test "default priority is low when not specified" do
    tool = CreateTaskTool.new
    result = JSON.parse(tool.call(title: "Low Priority Task"))

    assert_equal "low", result["priority"]
  end

  test "creates task in specified board_column" do
    tool = CreateTaskTool.new
    in_progress_col = board_columns(:in_progress)

    result = JSON.parse(tool.call(title: "In Progress Task", board_column_id: in_progress_col.id))

    assert_equal in_progress_col.id, result["board_column"]["id"]
    assert_equal "In Progress", result["board_column"]["name"]
  end

  test "creator_type is agent and creator_id is Current.agent_name" do
    tool = CreateTaskTool.new
    result = JSON.parse(tool.call(title: "Agent Created Task"))

    created_task = Task.find(result["id"])
    assert_equal "agent", created_task.creator_type
    assert_equal "test-agent", created_task.creator_id
  end

  test "creates task with all optional fields" do
    tool = CreateTaskTool.new
    todo_col = board_columns(:todo)

    result = JSON.parse(tool.call(
      title: "Full Task",
      description: "A detailed description",
      board_column_id: todo_col.id,
      priority: "high"
    ))

    assert_equal "Full Task", result["title"]
    assert_equal "A detailed description", result["description"]
    assert_equal "high", result["priority"]
    assert_equal todo_col.id, result["board_column"]["id"]
  end
end
