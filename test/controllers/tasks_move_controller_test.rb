require "test_helper"

class TasksMoveControllerTest < ActionDispatch::IntegrationTest
  # Route: PATCH /projects/:project_id/tasks/:id/move
  # Controller action: TasksController#move
  # Authorization: delegates to update? via `authorize @task, :update?`
  # set_project uses Project.find (no user scope) — non-owner reaches Pundit → 403

  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    @task       = tasks(:active_task)   # todo column, position 0
    @backlog    = board_columns(:backlog)
    @todo       = board_columns(:todo)
  end

  # --- authentication ---

  test "move redirects unauthenticated user to login" do
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @backlog.id, position: 0 }
    assert_redirected_to new_session_path
  end

  # --- authorization ---

  test "move returns 200 for project owner" do
    sign_in_as @user
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @todo.id, position: 0 }
    assert_response :ok
  end

  test "move returns 403 for non-owner" do
    sign_in_as @other_user
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @backlog.id, position: 0 }
    assert_response :forbidden
  end

  # --- same-column reposition ---

  test "move within same column updates position" do
    sign_in_as @user
    # active_task is at position 0 in todo; move it to position 1
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @todo.id, position: 1 }
    assert_response :ok
    assert_equal 1, @task.reload.position
  end

  test "move within same column keeps board_column_id unchanged" do
    sign_in_as @user
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @todo.id, position: 1 }
    assert_response :ok
    assert_equal @todo.id, @task.reload.board_column_id
  end

  # --- cross-column move ---

  test "move to a different column updates board_column_id" do
    sign_in_as @user
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @backlog.id, position: 0 }
    assert_response :ok
    assert_equal @backlog.id, @task.reload.board_column_id
  end

  test "move to a different column updates position" do
    sign_in_as @user
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @backlog.id, position: 0 }
    assert_response :ok
    assert_equal 0, @task.reload.position
  end

  test "move does not change task count" do
    sign_in_as @user
    assert_no_difference("Task.count") do
      patch move_project_task_url(@project, @task),
        params: { board_column_id: @backlog.id, position: 0 }
    end
  end

  # --- non-owner does not mutate task state ---

  test "move by non-owner does not change board_column_id" do
    sign_in_as @other_user
    original_column_id = @task.board_column_id
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @backlog.id, position: 0 }
    assert_equal original_column_id, @task.reload.board_column_id
  end

  test "move by non-owner does not change position" do
    sign_in_as @other_user
    original_position = @task.position
    patch move_project_task_url(@project, @task),
      params: { board_column_id: @backlog.id, position: 0 }
    assert_equal original_position, @task.reload.position
  end
end
