# frozen_string_literal: true

require "test_helper"

class UpdateChecklistToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "marks an incomplete checklist as completed" do
    tool = UpdateChecklistTool.new
    # task_checklist_1: completed=false
    checklist = checklists(:task_checklist_1)

    result = JSON.parse(tool.call(checklist_id: checklist.id, completed: true))

    assert_equal checklist.id, result["id"]
    assert_equal true, result["completed"]
    assert checklist.reload.completed
  end

  test "marks a completed checklist as incomplete" do
    tool = UpdateChecklistTool.new
    # task_checklist_2: completed=true
    checklist = checklists(:task_checklist_2)

    result = JSON.parse(tool.call(checklist_id: checklist.id, completed: false))

    assert_equal false, result["completed"]
    assert_not checklist.reload.completed
  end

  test "result includes id, content, completed, task_id" do
    tool = UpdateChecklistTool.new
    checklist = checklists(:task_checklist_1)

    result = JSON.parse(tool.call(checklist_id: checklist.id, completed: true))

    assert result.key?("id")
    assert result.key?("content")
    assert result.key?("completed")
    assert result.key?("task_id")
    assert_equal checklist.task_id, result["task_id"]
    assert_equal "Write unit tests", result["content"]
  end

  test "returns error for non-existent checklist_id" do
    tool = UpdateChecklistTool.new

    result = JSON.parse(tool.call(checklist_id: 0, completed: true))

    assert result.key?("error")
    assert_match(/0/, result["error"])
  end

  test "returns error when checklist belongs to a different project" do
    # high_priority_task는 user_two_project 소속
    # user_two_project에는 fixture checklist가 없으므로 inline으로 생성
    other_project = projects(:user_two_project)
    other_task = tasks(:high_priority_task)
    other_checklist = other_task.checklists.create!(
      content: "Other project checklist",
      completed: false,
      position: 0
    )

    # Current.project는 user_one_project이므로 other_checklist는 접근 불가
    tool = UpdateChecklistTool.new
    result = JSON.parse(tool.call(checklist_id: other_checklist.id, completed: true))

    assert result.key?("error"), "Checklist from another project should not be accessible"
    assert_not other_checklist.reload.completed, "Checklist should not have been updated"
  ensure
    other_checklist&.destroy
  end
end
