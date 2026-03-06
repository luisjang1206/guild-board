require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:regular)
    @record = users(:admin)
  end

  test "default policy denies index" do
    assert_not ApplicationPolicy.new(@user, @record).index?
  end

  test "default policy denies show" do
    assert_not ApplicationPolicy.new(@user, @record).show?
  end

  test "default policy denies create" do
    assert_not ApplicationPolicy.new(@user, @record).create?
  end

  test "default policy denies update" do
    assert_not ApplicationPolicy.new(@user, @record).update?
  end

  test "default policy denies destroy" do
    assert_not ApplicationPolicy.new(@user, @record).destroy?
  end
end
