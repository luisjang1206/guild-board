# frozen_string_literal: true

require "test_helper"

class TasksActivityLogTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user        = users(:regular)
    @project     = projects(:user_one_project)
    @task        = tasks(:active_task)
    @board_column = board_columns(:todo)
    @in_progress = board_columns(:in_progress)
  end

  test "create enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_tasks_url(@project),
        params: { task: { title: "Log Test Task", board_column_id: @board_column.id } }
    end
  end

  test "update enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      patch project_task_url(@project, @task),
        params: { task: { title: "Updated Title" } }
    end
  end

  test "move enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      patch move_project_task_url(@project, @task),
        params: { board_column_id: @in_progress.id, position: 0 }
    end
  end

  test "destroy enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      delete project_task_url(@project, @task)
    end
  end

  test "create enqueues job with task_created action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_tasks_url(@project),
        params: { task: { title: "Action Check Task", board_column_id: @board_column.id } }
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "task_created", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_equal "user", job_args["actor_type"]
    assert_equal @user.id.to_s, job_args["actor_id"]
  end

  test "destroy enqueues job with task_deleted action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      delete project_task_url(@project, @task)
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "task_deleted", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_equal @task.id, job_args["task_id"]
    assert_equal "user", job_args["actor_type"]
  end

  test "create with invalid params does not enqueue ActivityLogJob" do
    sign_in_as @user
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      post project_tasks_url(@project),
        params: { task: { title: "", board_column_id: @board_column.id } }
    end
  end

  test "update with invalid params does not enqueue ActivityLogJob" do
    sign_in_as @user
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      patch project_task_url(@project, @task),
        params: { task: { title: "" } }
    end
  end
end
