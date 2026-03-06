require "test_helper"

class Admin::ProjectKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular = users(:regular)
  end

  test "admin can list project keys" do
    post session_url, params: { email_address: @admin.email_address, password: "password123" }
    get admin_project_keys_url
    assert_response :success
  end

  test "regular user gets forbidden on index" do
    post session_url, params: { email_address: @regular.email_address, password: "password123" }
    get admin_project_keys_url
    assert_response :forbidden
  end

  test "unauthenticated user gets redirected" do
    get admin_project_keys_url
    assert_redirected_to new_session_url
  end
end
