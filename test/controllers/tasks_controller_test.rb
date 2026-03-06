# frozen_string_literal: true

require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    @task       = tasks(:active_task)
    @board_column = board_columns(:todo)
  end

  # --- new ---

  test "new redirects unauthenticated user to login" do
    get new_project_task_url(@project)
    assert_redirected_to new_session_path
  end

  test "new returns success for project owner" do
    sign_in_as @user
    get new_project_task_url(@project)
    assert_response :success
  end

  test "new returns 403 for non-owner" do
    sign_in_as @other_user
    get new_project_task_url(@project)
    assert_response :forbidden
  end

  # --- create ---

  test "create redirects unauthenticated user to login" do
    post project_tasks_url(@project), params: { task: { title: "New Task", board_column_id: @board_column.id } }
    assert_redirected_to new_session_path
  end

  test "create with valid params creates a task" do
    sign_in_as @user
    assert_difference("Task.count", 1) do
      post project_tasks_url(@project), params: { task: { title: "New Task", board_column_id: @board_column.id } }
    end
    created = Task.last
    assert_equal "New Task", created.title
    assert_equal "user", created.creator_type
    assert_equal @user.id.to_s, created.creator_id
  end

  test "create redirects even for turbo_stream requests (broadcast handles DOM update)" do
    sign_in_as @user
    post project_tasks_url(@project),
      params: { task: { title: "Turbo Task", board_column_id: @board_column.id } },
      as: :turbo_stream
    assert_redirected_to project_board_path(@project)
  end

  test "create with invalid params renders new with 422" do
    sign_in_as @user
    assert_no_difference("Task.count") do
      post project_tasks_url(@project), params: { task: { title: "", board_column_id: @board_column.id } }
    end
    assert_response :unprocessable_entity
  end

  test "create returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Task.count") do
      post project_tasks_url(@project), params: { task: { title: "Hijack Task", board_column_id: @board_column.id } }
    end
    assert_response :forbidden
  end

  # --- show ---

  test "show redirects unauthenticated user to login" do
    get project_task_url(@project, @task)
    assert_redirected_to new_session_path
  end

  test "show returns success for project owner" do
    sign_in_as @user
    get project_task_url(@project, @task)
    assert_response :success
  end

  test "show returns 403 for non-owner" do
    sign_in_as @other_user
    get project_task_url(@project, @task)
    assert_response :forbidden
  end

  # --- edit ---

  test "edit redirects unauthenticated user to login" do
    get edit_project_task_url(@project, @task)
    assert_redirected_to new_session_path
  end

  test "edit returns success for project owner" do
    sign_in_as @user
    get edit_project_task_url(@project, @task)
    assert_response :success
  end

  test "edit returns 403 for non-owner" do
    sign_in_as @other_user
    get edit_project_task_url(@project, @task)
    assert_response :forbidden
  end

  # --- update ---

  test "update redirects unauthenticated user to login" do
    patch project_task_url(@project, @task), params: { task: { title: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "update with valid params updates the task" do
    sign_in_as @user
    patch project_task_url(@project, @task), params: { task: { title: "Updated Title" } }
    assert_redirected_to project_board_path(@project)
    assert_equal "Updated Title", @task.reload.title
  end

  test "update with valid params and turbo_stream returns turbo_stream response" do
    sign_in_as @user
    patch project_task_url(@project, @task),
      params: { task: { title: "Turbo Update" } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "update with invalid params renders edit with 422" do
    sign_in_as @user
    patch project_task_url(@project, @task), params: { task: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update returns 403 for non-owner" do
    sign_in_as @other_user
    patch project_task_url(@project, @task), params: { task: { title: "Hacked" } }
    assert_response :forbidden
    assert_not_equal "Hacked", @task.reload.title
  end

  # --- destroy ---

  test "destroy redirects unauthenticated user to login" do
    delete project_task_url(@project, @task)
    assert_redirected_to new_session_path
  end

  test "destroy soft-deletes the task and sets deleted_at" do
    sign_in_as @user
    assert_nil @task.deleted_at
    delete project_task_url(@project, @task)
    assert_redirected_to project_board_path(@project)
    assert_not_nil @task.reload.deleted_at
  end

  test "destroy does not permanently remove the task from the database" do
    sign_in_as @user
    assert_no_difference("Task.count") do
      delete project_task_url(@project, @task)
    end
  end

  test "destroy returns 403 for non-owner" do
    sign_in_as @other_user
    delete project_task_url(@project, @task)
    assert_response :forbidden
    assert_nil @task.reload.deleted_at
  end
end
