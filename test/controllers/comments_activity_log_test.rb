# frozen_string_literal: true

require "test_helper"

class CommentsActivityLogTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user    = users(:regular)
    @project = projects(:user_one_project)
    @task    = tasks(:active_task)
  end

  test "create comment enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_task_comments_url(@project, @task),
        params: { comment: { content: "Test comment" } }
    end
  end

  test "create comment enqueues job with comment_added action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_task_comments_url(@project, @task),
        params: { comment: { content: "Action check comment" } }
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "comment_added", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_equal @task.id, job_args["task_id"]
    assert_equal "user", job_args["actor_type"]
  end

  test "create comment with blank content does not enqueue ActivityLogJob" do
    sign_in_as @user
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      post project_task_comments_url(@project, @task),
        params: { comment: { content: "" } }
    end
  end
end
