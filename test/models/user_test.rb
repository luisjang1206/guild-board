require "test_helper"

class UserTest < ActiveSupport::TestCase
  # -- Role enum --
  test "default role is user" do
    user = User.new(email_address: "new@example.com", password: "password123", password_confirmation: "password123")
    assert user.user?
  end

  test "admin role" do
    assert users(:admin).admin?
  end

  test "super_admin role" do
    assert users(:super_admin).super_admin?
  end

  # -- Password validation --
  test "password minimum 8 characters rejects short" do
    user = User.new(email_address: "short@example.com", password: "short12", password_confirmation: "short12")
    assert_not user.valid?
    assert user.errors[:password].any?, "Expected password errors but got none"
  end

  test "password valid at 8 characters" do
    user = User.new(email_address: "valid@example.com", password: "12345678", password_confirmation: "12345678")
    assert user.valid?
  end

  # -- Email normalization --
  test "email normalization strips and downcases" do
    user = User.create!(email_address: "  TEST@Example.COM  ", password: "password123", password_confirmation: "password123")
    assert_equal "test@example.com", user.email_address
  end

  # -- generates_token_for :email_confirmation --
  test "generates email_confirmation token and resolves" do
    user = users(:regular)
    token = user.generate_token_for(:email_confirmation)
    assert_not_nil token
    found = User.find_by_token_for(:email_confirmation, token)
    assert_equal user, found
  end

  # -- generates_token_for :magic_link --
  test "generates magic_link token and resolves" do
    user = users(:regular)
    token = user.generate_token_for(:magic_link)
    assert_not_nil token
    found = User.find_by_token_for(:magic_link, token)
    assert_equal user, found
  end

  test "magic_link token invalidated after update" do
    user = users(:regular)
    token = user.generate_token_for(:magic_link)
    user.touch
    found = User.find_by_token_for(:magic_link, token)
    assert_nil found
  end
end
