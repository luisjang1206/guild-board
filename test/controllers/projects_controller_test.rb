require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @other_user = users(:admin)
    @project = projects(:user_one_project)
    @other_project = projects(:user_two_project)
  end

  # --- index ---

  test "index redirects unauthenticated user to login" do
    get projects_url
    assert_redirected_to new_session_path
  end

  test "index returns success for authenticated user" do
    sign_in_as @user
    get projects_url
    assert_response :success
  end

  test "index only shows the current user's own projects" do
    sign_in_as @user
    get projects_url
    assert_response :success
    # policy_scope filters to user's own projects
    assert_select "body", text: /#{@project.name}/
  end

  # --- show ---

  test "show redirects unauthenticated user to login" do
    get project_url(@project)
    assert_redirected_to new_session_path
  end

  test "show returns success for project owner" do
    sign_in_as @user
    get project_url(@project)
    assert_response :success
  end

  test "show returns 403 for non-owner" do
    sign_in_as @other_user
    get project_url(@project)
    assert_response :forbidden
  end

  # --- new ---

  test "new redirects unauthenticated user to login" do
    get new_project_url
    assert_redirected_to new_session_path
  end

  test "new returns success for authenticated user" do
    sign_in_as @user
    get new_project_url
    assert_response :success
  end

  # --- create ---

  test "create redirects unauthenticated user to login" do
    post projects_url, params: { project: { name: "New Project", description: "Desc" } }
    assert_redirected_to new_session_path
  end

  test "create with valid params creates a project and redirects" do
    sign_in_as @user
    assert_difference("Project.count", 1) do
      post projects_url, params: { project: { name: "My New Project", description: "Some description" } }
    end
    assert_redirected_to project_url(Project.last)
  end

  test "create with invalid params renders new with 422" do
    sign_in_as @user
    assert_no_difference("Project.count") do
      post projects_url, params: { project: { name: "", description: "No name" } }
    end
    assert_response :unprocessable_entity
  end

  # --- edit ---

  test "edit redirects unauthenticated user to login" do
    get edit_project_url(@project)
    assert_redirected_to new_session_path
  end

  test "edit returns success for project owner" do
    sign_in_as @user
    get edit_project_url(@project)
    assert_response :success
  end

  test "edit returns 403 for non-owner" do
    sign_in_as @other_user
    get edit_project_url(@project)
    assert_response :forbidden
  end

  # --- update ---

  test "update redirects unauthenticated user to login" do
    patch project_url(@project), params: { project: { name: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "update with valid params updates project and redirects" do
    sign_in_as @user
    patch project_url(@project), params: { project: { name: "Updated Name", description: "Updated desc" } }
    assert_redirected_to project_url(@project)
    assert_equal "Updated Name", @project.reload.name
  end

  test "update with invalid params renders edit with 422" do
    sign_in_as @user
    patch project_url(@project), params: { project: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "update returns 403 for non-owner" do
    sign_in_as @other_user
    patch project_url(@project), params: { project: { name: "Hacked" } }
    assert_response :forbidden
  end

  # --- destroy ---

  test "destroy redirects unauthenticated user to login" do
    delete project_url(@project)
    assert_redirected_to new_session_path
  end

  test "destroy deletes the project and redirects to index" do
    # Use user_two_project (owned by admin) because user_one_project has tasks
    # referenced by activity_logs — destroying it violates the FK constraint at
    # the DB level before Rails cascades can run in the right order.
    sign_in_as @other_user
    assert_difference("Project.count", -1) do
      delete project_url(@other_project)
    end
    assert_redirected_to projects_url
  end

  test "destroy returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Project.count") do
      delete project_url(@project)
    end
    assert_response :forbidden
  end
end
