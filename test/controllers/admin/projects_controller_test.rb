require "test_helper"

class Admin::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular = users(:regular)
    @project = projects(:user_one_project)
  end

  test "admin can list projects" do
    post session_url, params: { email_address: @admin.email_address, password: "password123" }
    get admin_projects_url
    assert_response :success
  end

  test "admin can show project" do
    post session_url, params: { email_address: @admin.email_address, password: "password123" }
    get admin_project_url(@project)
    assert_response :success
  end

  test "regular user gets forbidden on index" do
    post session_url, params: { email_address: @regular.email_address, password: "password123" }
    get admin_projects_url
    assert_response :forbidden
  end

  test "regular user gets forbidden on show" do
    post session_url, params: { email_address: @regular.email_address, password: "password123" }
    get admin_project_url(@project)
    assert_response :forbidden
  end

  test "unauthenticated user gets redirected" do
    get admin_projects_url
    assert_redirected_to new_session_url
  end
end
