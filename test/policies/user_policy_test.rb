require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @regular = users(:regular)
    @admin = users(:admin)
    @super_admin = users(:super_admin)
  end

  # -- index? --
  test "admin can index users" do
    assert UserPolicy.new(@admin, User).index?
  end

  test "super_admin can index users" do
    assert UserPolicy.new(@super_admin, User).index?
  end

  test "regular user cannot index users" do
    assert_not UserPolicy.new(@regular, User).index?
  end

  # -- show? --
  test "user can show self" do
    assert UserPolicy.new(@regular, @regular).show?
  end

  test "user cannot show other user" do
    assert_not UserPolicy.new(@regular, @admin).show?
  end

  test "admin can show any user" do
    assert UserPolicy.new(@admin, @regular).show?
  end

  # -- update? --
  test "user can update self" do
    assert UserPolicy.new(@regular, @regular).update?
  end

  test "user cannot update other user" do
    assert_not UserPolicy.new(@regular, @admin).update?
  end

  test "admin cannot update other user" do
    assert_not UserPolicy.new(@admin, @regular).update?
  end

  test "super_admin can update any user" do
    assert UserPolicy.new(@super_admin, @regular).update?
  end

  # -- change_role? --
  test "only super_admin can change role" do
    assert UserPolicy.new(@super_admin, @regular).change_role?
  end

  test "admin cannot change role" do
    assert_not UserPolicy.new(@admin, @regular).change_role?
  end

  test "regular user cannot change role" do
    assert_not UserPolicy.new(@regular, @regular).change_role?
  end

  # -- Scope --
  test "scope for admin returns all users" do
    scope = UserPolicy::Scope.new(@admin, User).resolve
    assert_equal User.count, scope.count
  end

  test "scope for regular user returns only self" do
    scope = UserPolicy::Scope.new(@regular, User).resolve
    assert_equal 1, scope.count
    assert_includes scope, @regular
  end
end
