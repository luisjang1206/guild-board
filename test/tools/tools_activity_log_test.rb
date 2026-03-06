# frozen_string_literal: true

require "test_helper"

class ToolsActivityLogTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    Current.project    = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  # --- CreateTaskTool ---

  test "CreateTaskTool enqueues ActivityLogJob" do
    assert_enqueued_with(job: ActivityLogJob) do
      CreateTaskTool.new.call(title: "Log Test Task")
    end
  end

  test "CreateTaskTool enqueues job with task_created action and agent actor" do
    assert_enqueued_with(job: ActivityLogJob) do
      CreateTaskTool.new.call(title: "Action Check Task")
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "task_created", job_args["action"]
    assert_equal projects(:user_one_project).id, job_args["project_id"]
    assert_equal "agent", job_args["actor_type"]
    assert_equal "test-agent", job_args["actor_id"]
  end

  # --- UpdateTaskTool ---

  test "UpdateTaskTool enqueues ActivityLogJob" do
    task = tasks(:active_task)
    assert_enqueued_with(job: ActivityLogJob) do
      UpdateTaskTool.new.call(task_id: task.id, title: "Updated Title")
    end
  end

  test "UpdateTaskTool enqueues job with task_updated action" do
    task = tasks(:active_task)
    assert_enqueued_with(job: ActivityLogJob) do
      UpdateTaskTool.new.call(task_id: task.id, title: "Action Check Update")
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "task_updated", job_args["action"]
    assert_equal task.id, job_args["task_id"]
    assert_equal "agent", job_args["actor_type"]
    assert_equal "test-agent", job_args["actor_id"]
  end

  test "UpdateTaskTool does not enqueue ActivityLogJob for non-existent task" do
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      UpdateTaskTool.new.call(task_id: 0, title: "Ghost Title")
    end
  end

  # --- MoveTaskTool ---

  test "MoveTaskTool enqueues ActivityLogJob" do
    task = tasks(:active_task)
    assert_enqueued_with(job: ActivityLogJob) do
      MoveTaskTool.new.call(task_id: task.id, board_column: "In Progress")
    end
  end

  test "MoveTaskTool enqueues job with task_moved action" do
    task = tasks(:active_task)
    assert_enqueued_with(job: ActivityLogJob) do
      MoveTaskTool.new.call(task_id: task.id, board_column: "In Progress")
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "task_moved", job_args["action"]
    assert_equal task.id, job_args["task_id"]
    assert_equal "agent", job_args["actor_type"]
    assert_equal "test-agent", job_args["actor_id"]
  end

  test "MoveTaskTool does not enqueue ActivityLogJob for non-existent task" do
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      MoveTaskTool.new.call(task_id: 0, board_column: "In Progress")
    end
  end

  # --- AddCommentTool ---

  test "AddCommentTool enqueues ActivityLogJob" do
    task = tasks(:active_task)
    assert_enqueued_with(job: ActivityLogJob) do
      AddCommentTool.new.call(task_id: task.id, content: "Log test comment")
    end
  end

  test "AddCommentTool enqueues job with comment_added action" do
    task = tasks(:active_task)
    assert_enqueued_with(job: ActivityLogJob) do
      AddCommentTool.new.call(task_id: task.id, content: "Action check comment")
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "comment_added", job_args["action"]
    assert_equal task.id, job_args["task_id"]
    assert_equal "agent", job_args["actor_type"]
    assert_equal "test-agent", job_args["actor_id"]
  end

  test "AddCommentTool does not enqueue ActivityLogJob for non-existent task" do
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      AddCommentTool.new.call(task_id: 0, content: "Ghost comment")
    end
  end

  # --- UpdateChecklistTool ---

  test "UpdateChecklistTool enqueues ActivityLogJob" do
    checklist = checklists(:task_checklist_1)
    assert_enqueued_with(job: ActivityLogJob) do
      UpdateChecklistTool.new.call(checklist_id: checklist.id, completed: true)
    end
  end

  test "UpdateChecklistTool enqueues job with checklist_toggled action" do
    checklist = checklists(:task_checklist_1)
    assert_enqueued_with(job: ActivityLogJob) do
      UpdateChecklistTool.new.call(checklist_id: checklist.id, completed: true)
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "checklist_toggled", job_args["action"]
    assert_equal checklist.task_id, job_args["task_id"]
    assert_equal "agent", job_args["actor_type"]
    assert_equal "test-agent", job_args["actor_id"]
  end

  test "UpdateChecklistTool does not enqueue ActivityLogJob for non-existent checklist" do
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      UpdateChecklistTool.new.call(checklist_id: 0, completed: true)
    end
  end
end
