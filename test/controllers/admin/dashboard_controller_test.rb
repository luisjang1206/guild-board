require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular = users(:regular)
  end

  test "admin can access dashboard" do
    post session_url, params: { email_address: @admin.email_address, password: "password123" }
    get admin_root_url
    assert_response :success
  end

  test "regular user gets forbidden" do
    post session_url, params: { email_address: @regular.email_address, password: "password123" }
    get admin_root_url
    assert_response :forbidden
  end

  test "unauthenticated user gets redirected" do
    get admin_root_url
    assert_redirected_to new_session_url
  end
end
