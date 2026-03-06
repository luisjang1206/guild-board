require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular = users(:regular)
  end

  test "admin can list users" do
    post session_url, params: { email_address: @admin.email_address, password: "password123" }
    get admin_users_url
    assert_response :success
  end

  test "admin can show user" do
    post session_url, params: { email_address: @admin.email_address, password: "password123" }
    get admin_user_url(@regular)
    assert_response :success
  end

  test "regular user gets forbidden on index" do
    post session_url, params: { email_address: @regular.email_address, password: "password123" }
    get admin_users_url
    assert_response :forbidden
  end

  test "regular user gets forbidden on show" do
    post session_url, params: { email_address: @regular.email_address, password: "password123" }
    get admin_user_url(@admin)
    assert_response :forbidden
  end

  test "unauthenticated user gets redirected" do
    get admin_users_url
    assert_redirected_to new_session_url
  end
end
