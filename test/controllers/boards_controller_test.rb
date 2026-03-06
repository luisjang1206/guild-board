require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @other_user = users(:admin)
    @project = projects(:user_one_project)
    @other_project = projects(:user_two_project)
  end

  # --- show ---

  test "show redirects unauthenticated user to login" do
    get project_board_url(@project)
    assert_redirected_to new_session_path
  end

  test "show returns success for project owner" do
    sign_in_as @user
    get project_board_url(@project)
    assert_response :success
  end

  test "show returns 403 for non-owner" do
    sign_in_as @other_user
    get project_board_url(@project)
    assert_response :forbidden
  end

  test "show returns 404 for nonexistent project" do
    sign_in_as @user
    get "/projects/0/board"
    assert_response :not_found
  end
end
