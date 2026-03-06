# frozen_string_literal: true

require "test_helper"

class BoardColumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    # todo has active_task — used for "cannot delete" tests
    @column_with_tasks = board_columns(:todo)
    # done has no tasks — used for successful deletion tests
    @column_empty = board_columns(:done)
  end

  # --- create ---

  test "create redirects unauthenticated user to login" do
    post project_board_columns_url(@project), params: { board_column: { name: "New Column" } }
    assert_redirected_to new_session_path
  end

  test "create with valid params creates a board column" do
    sign_in_as @user
    assert_difference("BoardColumn.count", 1) do
      post project_board_columns_url(@project), params: { board_column: { name: "New Column" } }
    end
    assert_redirected_to project_board_path(@project)
    assert_equal "New Column", BoardColumn.last.name
  end

  test "create with valid params and turbo_stream returns turbo_stream response" do
    sign_in_as @user
    post project_board_columns_url(@project),
      params: { board_column: { name: "Turbo Column" } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "create with invalid params redirects with alert for empty name" do
    sign_in_as @user
    assert_no_difference("BoardColumn.count") do
      post project_board_columns_url(@project), params: { board_column: { name: "" } }
    end
    assert_redirected_to project_board_path(@project)
    assert flash[:alert].present?, "Expected an alert flash message to be set"
  end

  test "create returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("BoardColumn.count") do
      post project_board_columns_url(@project), params: { board_column: { name: "Hijack Column" } }
    end
    assert_response :forbidden
  end

  # --- update ---

  test "update redirects unauthenticated user to login" do
    patch project_board_column_url(@project, @column_with_tasks), params: { board_column: { name: "Renamed" } }
    assert_redirected_to new_session_path
  end

  test "update with valid params updates the column name and returns ok" do
    sign_in_as @user
    patch project_board_column_url(@project, @column_with_tasks), params: { board_column: { name: "Renamed Column" } }
    assert_response :ok
    assert_equal "Renamed Column", @column_with_tasks.reload.name
  end

  test "update with invalid params returns 422 for empty name" do
    sign_in_as @user
    patch project_board_column_url(@project, @column_with_tasks), params: { board_column: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal "Todo", @column_with_tasks.reload.name
  end

  test "update returns 403 for non-owner" do
    sign_in_as @other_user
    patch project_board_column_url(@project, @column_with_tasks), params: { board_column: { name: "Hacked" } }
    assert_response :forbidden
    assert_not_equal "Hacked", @column_with_tasks.reload.name
  end

  # --- destroy ---

  test "destroy redirects unauthenticated user to login" do
    delete project_board_column_url(@project, @column_empty)
    assert_redirected_to new_session_path
  end

  test "destroy removes an empty column and redirects" do
    sign_in_as @user
    assert_difference("BoardColumn.count", -1) do
      delete project_board_column_url(@project, @column_empty)
    end
    assert_redirected_to project_board_path(@project)
  end

  test "destroy prevents deletion of column with active tasks and redirects with alert" do
    sign_in_as @user
    assert_no_difference("BoardColumn.count") do
      delete project_board_column_url(@project, @column_with_tasks)
    end
    assert_redirected_to project_board_path(@project)
    assert_equal I18n.t("board_columns.cannot_delete_with_tasks"), flash[:alert]
  end

  test "destroy of empty column with turbo_stream returns turbo_stream response" do
    sign_in_as @user
    delete project_board_column_url(@project, @column_empty), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "destroy returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("BoardColumn.count") do
      delete project_board_column_url(@project, @column_empty)
    end
    assert_response :forbidden
  end

  # --- move ---

  test "move redirects unauthenticated user to login" do
    patch move_project_board_column_url(@project, @column_with_tasks), params: { position: 0 }
    assert_redirected_to new_session_path
  end

  test "move updates the column position and returns ok" do
    sign_in_as @user
    patch move_project_board_column_url(@project, @column_with_tasks), params: { position: 0 }
    assert_response :ok
    assert_equal 0, @column_with_tasks.reload.position
  end

  test "move returns 403 for non-owner" do
    sign_in_as @other_user
    original_position = @column_with_tasks.position
    patch move_project_board_column_url(@project, @column_with_tasks), params: { position: 0 }
    assert_response :forbidden
    assert_equal original_position, @column_with_tasks.reload.position
  end
end
