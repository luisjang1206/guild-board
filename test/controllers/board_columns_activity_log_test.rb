# frozen_string_literal: true

require "test_helper"

class BoardColumnsActivityLogTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user        = users(:regular)
    @project     = projects(:user_one_project)
    @done_column = board_columns(:done)   # empty — safe for destroy tests
    @todo_column = board_columns(:todo)   # has active_task — safe for update tests
  end

  test "create column enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_board_columns_url(@project),
        params: { board_column: { name: "New Column" } }
    end
  end

  test "create column enqueues job with column_created action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_board_columns_url(@project),
        params: { board_column: { name: "Action Check Column" } }
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "column_created", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_nil job_args["task_id"]
    assert_equal "user", job_args["actor_type"]
  end

  test "update column enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      patch project_board_column_url(@project, @todo_column),
        params: { board_column: { name: "Renamed" } }
    end
  end

  test "update column enqueues job with column_updated action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      patch project_board_column_url(@project, @todo_column),
        params: { board_column: { name: "Action Renamed" } }
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "column_updated", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_nil job_args["task_id"]
    assert_equal "user", job_args["actor_type"]
  end

  test "destroy empty column enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      delete project_board_column_url(@project, @done_column)
    end
  end

  test "destroy column enqueues job with column_deleted action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      delete project_board_column_url(@project, @done_column)
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "column_deleted", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_nil job_args["task_id"]
    assert_equal "user", job_args["actor_type"]
  end

  test "destroy column with active tasks does not enqueue ActivityLogJob" do
    sign_in_as @user
    # todo_column has active_task — deletion is prevented
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      delete project_board_column_url(@project, @todo_column)
    end
  end

  test "create column with invalid params does not enqueue ActivityLogJob" do
    sign_in_as @user
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      post project_board_columns_url(@project),
        params: { board_column: { name: "" } }
    end
  end

  test "update column with invalid params does not enqueue ActivityLogJob" do
    sign_in_as @user
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      patch project_board_column_url(@project, @todo_column),
        params: { board_column: { name: "" } }
    end
  end
end
