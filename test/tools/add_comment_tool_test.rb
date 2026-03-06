# frozen_string_literal: true

require "test_helper"

class AddCommentToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "creates a comment on the task" do
    tool = AddCommentTool.new
    task = tasks(:active_task)

    assert_difference "Comment.count", 1 do
      @result = JSON.parse(tool.call(task_id: task.id, content: "New agent comment"))
    end

    assert_equal "New agent comment", @result["content"]
    assert @result.key?("id")
    assert @result.key?("created_at")
  end

  test "comment author_type is agent" do
    tool = AddCommentTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, content: "Agent says hi"))

    assert_equal "agent", result["author_type"]
  end

  test "comment author_id is Current.agent_name" do
    tool = AddCommentTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, content: "Authored comment"))

    assert_equal "test-agent", result["author_id"]
  end

  test "created comment is persisted with correct data" do
    tool = AddCommentTool.new
    task = tasks(:active_task)

    result = JSON.parse(tool.call(task_id: task.id, content: "Persisted comment"))

    comment = Comment.find(result["id"])
    assert_equal "Persisted comment", comment.content
    assert_equal "agent", comment.author_type
    assert_equal "test-agent", comment.author_id
    assert_equal task.id, comment.task_id
  end

  test "returns error for non-existent task_id" do
    tool = AddCommentTool.new

    assert_no_difference "Comment.count" do
      @result = JSON.parse(tool.call(task_id: 0, content: "Should fail"))
    end

    assert @result.key?("error")
    assert_match(/0/, @result["error"])
  end

  test "returns error for soft-deleted task" do
    tool = AddCommentTool.new
    deleted = tasks(:deleted_task)

    assert_no_difference "Comment.count" do
      @result = JSON.parse(tool.call(task_id: deleted.id, content: "Should fail"))
    end

    assert @result.key?("error"), "Soft-deleted task should not accept comments"
  end
end
