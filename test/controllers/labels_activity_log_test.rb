# frozen_string_literal: true

require "test_helper"

class LabelsActivityLogTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user    = users(:regular)
    @project = projects(:user_one_project)
    @label   = labels(:frontend)
  end

  test "create label enqueues ActivityLogJob" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_labels_url(@project),
        params: { label: { name: "Bug", color: "#FF0000" } }
    end
  end

  test "create label enqueues job with label_created action" do
    sign_in_as @user
    assert_enqueued_with(job: ActivityLogJob) do
      post project_labels_url(@project),
        params: { label: { name: "Feature", color: "#00FF00" } }
    end
    job_args = enqueued_jobs.last[:args].first
    assert_equal "label_created", job_args["action"]
    assert_equal @project.id, job_args["project_id"]
    assert_nil job_args["task_id"]
    assert_equal "user", job_args["actor_type"]
  end

  test "create label with invalid params does not enqueue ActivityLogJob" do
    sign_in_as @user
    assert_no_enqueued_jobs(only: ActivityLogJob) do
      post project_labels_url(@project),
        params: { label: { name: "", color: "#FF0000" } }
    end
  end
end
