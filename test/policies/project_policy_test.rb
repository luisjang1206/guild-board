require "test_helper"

class ProjectPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:regular)
    @other_user = users(:admin)
    @project = projects(:user_one_project)
  end

  test "authenticated user can index projects" do
    assert ProjectPolicy.new(@owner, Project).index?
  end

  test "unauthenticated user cannot index projects" do
    assert_not ProjectPolicy.new(nil, Project).index?
  end

  test "owner can show project" do
    assert ProjectPolicy.new(@owner, @project).show?
  end

  test "non-owner cannot show project" do
    assert_not ProjectPolicy.new(@other_user, @project).show?
  end

  test "authenticated user can create project" do
    assert ProjectPolicy.new(@owner, Project.new).create?
  end

  test "unauthenticated user cannot create project" do
    assert_not ProjectPolicy.new(nil, Project.new).create?
  end

  test "owner can update project" do
    assert ProjectPolicy.new(@owner, @project).update?
  end

  test "non-owner cannot update project" do
    assert_not ProjectPolicy.new(@other_user, @project).update?
  end

  test "owner can destroy project" do
    assert ProjectPolicy.new(@owner, @project).destroy?
  end

  test "non-owner cannot destroy project" do
    assert_not ProjectPolicy.new(@other_user, @project).destroy?
  end

  test "scope resolves to user's own projects" do
    scope = ProjectPolicy::Scope.new(@owner, Project).resolve
    assert_includes scope, @project
    assert_not_includes scope, projects(:user_two_project)
  end
end
