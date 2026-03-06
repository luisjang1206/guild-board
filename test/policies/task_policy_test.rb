require "test_helper"

class TaskPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:regular)
    @other_user = users(:admin)
    @task = tasks(:active_task)
  end

  test "project owner can show task" do
    assert TaskPolicy.new(@owner, @task).show?
  end

  test "non-owner cannot show task" do
    assert_not TaskPolicy.new(@other_user, @task).show?
  end

  test "project owner can create task" do
    assert TaskPolicy.new(@owner, @task).create?
  end

  test "non-owner cannot create task" do
    assert_not TaskPolicy.new(@other_user, @task).create?
  end

  test "project owner can update task" do
    assert TaskPolicy.new(@owner, @task).update?
  end

  test "non-owner cannot update task" do
    assert_not TaskPolicy.new(@other_user, @task).update?
  end

  test "project owner can destroy task" do
    assert TaskPolicy.new(@owner, @task).destroy?
  end

  test "non-owner cannot destroy task" do
    assert_not TaskPolicy.new(@other_user, @task).destroy?
  end
end
