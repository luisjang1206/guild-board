require "test_helper"

class ProjectKeyPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:regular)
    @other_user = users(:admin)
    @project_key = project_keys(:default_key)
  end

  test "project owner can index keys" do
    assert ProjectKeyPolicy.new(@owner, @project_key).index?
  end

  test "non-owner cannot index keys" do
    assert_not ProjectKeyPolicy.new(@other_user, @project_key).index?
  end

  test "project owner can create key" do
    assert ProjectKeyPolicy.new(@owner, @project_key).create?
  end

  test "non-owner cannot create key" do
    assert_not ProjectKeyPolicy.new(@other_user, @project_key).create?
  end

  test "project owner can destroy key" do
    assert ProjectKeyPolicy.new(@owner, @project_key).destroy?
  end

  test "non-owner cannot destroy key" do
    assert_not ProjectKeyPolicy.new(@other_user, @project_key).destroy?
  end

  test "project owner can toggle active" do
    assert ProjectKeyPolicy.new(@owner, @project_key).toggle_active?
  end

  test "non-owner cannot toggle active" do
    assert_not ProjectKeyPolicy.new(@other_user, @project_key).toggle_active?
  end

  test "project owner can regenerate key" do
    assert ProjectKeyPolicy.new(@owner, @project_key).regenerate?
  end

  test "non-owner cannot regenerate key" do
    assert_not ProjectKeyPolicy.new(@other_user, @project_key).regenerate?
  end
end
