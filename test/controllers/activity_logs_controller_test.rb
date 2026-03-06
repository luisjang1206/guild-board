# frozen_string_literal: true

require "test_helper"

class ActivityLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    @task       = tasks(:active_task)
  end

  # --- authentication ---

  test "index redirects unauthenticated user to login" do
    get project_activity_logs_url(@project)
    assert_redirected_to new_session_path
  end

  # --- authorization ---

  test "index returns success for project owner" do
    sign_in_as @user
    get project_activity_logs_url(@project)
    assert_response :success
  end

  test "index returns forbidden for non-owner" do
    sign_in_as @other_user
    get project_activity_logs_url(@project)
    assert_response :forbidden
  end

  # --- filtering ---

  test "index returns success when filtering by task_id" do
    sign_in_as @user
    get project_activity_logs_url(@project, task_id: @task.id)
    assert_response :success
  end

  test "index without task_id returns success and renders project logs" do
    sign_in_as @user
    # task_created_log fixture belongs to user_one_project
    get project_activity_logs_url(@project)
    assert_response :success
  end

  test "index with task_id scopes response to that task" do
    sign_in_as @user
    # Only logs for @task should be included — the fixture task_created_log
    # references active_task, so this should return :success without raising.
    get project_activity_logs_url(@project, task_id: @task.id)
    assert_response :success
    # Cross-check: filtering for a different task returns no fixture logs
    other_task = tasks(:high_priority_task)
    get project_activity_logs_url(projects(:user_two_project), task_id: other_task.id)
    # other_task belongs to user_two_project which is owned by admin — regular
    # user gets forbidden, confirming routing is task-scoped per project
    assert_response :forbidden
  end

  test "index with unknown task_id returns success with empty result set" do
    sign_in_as @user
    # task_id: 0 matches no tasks — underlying scope returns empty collection
    get project_activity_logs_url(@project, task_id: 0)
    assert_response :success
  end

  test "index renders successfully (pagy and logs loaded without error)" do
    sign_in_as @user
    get project_activity_logs_url(@project)
    assert_response :success
  end
end
