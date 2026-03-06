require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
  end

  test "get new renders login form" do
    get new_session_url
    assert_response :success
  end

  test "create with valid credentials logs in and redirects" do
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    assert_redirected_to root_url
  end

  test "create with invalid credentials redirects with alert" do
    post session_url, params: { email_address: @user.email_address, password: "wrongpassword" }
    assert_redirected_to new_session_url
  end

  test "destroy logs out and redirects" do
    post session_url, params: { email_address: @user.email_address, password: "password123" }

    delete session_url
    assert_redirected_to new_session_url
  end
end
