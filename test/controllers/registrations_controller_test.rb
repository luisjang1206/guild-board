require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "get new renders registration form" do
    get new_registration_url
    assert_response :success
  end

  test "create with valid params creates user and redirects" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: { email_address: "newuser@example.com", password: "password123", password_confirmation: "password123" }
      }
    end
    assert_redirected_to root_url
  end

  test "create with short password renders form with errors" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: { email_address: "short@example.com", password: "short", password_confirmation: "short" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with duplicate email renders form with errors" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: { email_address: users(:regular).email_address, password: "password123", password_confirmation: "password123" }
      }
    end
    assert_response :unprocessable_entity
  end
end
