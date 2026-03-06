require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  # -- Validations --

  test "valid with name and user" do
    project = Project.new(name: "My Project", user: users(:regular))
    assert project.valid?
  end

  test "invalid without name" do
    project = Project.new(user: users(:regular))
    assert_not project.valid?
    assert project.errors[:name].any?
  end

  test "invalid with blank name" do
    project = Project.new(name: "  ", user: users(:regular))
    assert_not project.valid?
    assert project.errors[:name].any?
  end

  test "invalid when name exceeds 100 characters" do
    project = Project.new(name: "a" * 101, user: users(:regular))
    assert_not project.valid?
    assert project.errors[:name].any?
  end

  test "valid when name is exactly 100 characters" do
    project = Project.new(name: "a" * 100, user: users(:regular))
    assert project.valid?
  end

  test "invalid without user" do
    project = Project.new(name: "Orphan Project")
    assert_not project.valid?
    assert project.errors[:user].any?
  end

  # -- Associations --

  test "belongs to user" do
    project = projects(:user_one_project)
    assert_equal users(:regular), project.user
  end

  test "has many board_columns" do
    project = projects(:user_one_project)
    assert_respond_to project, :board_columns
    assert project.board_columns.count >= 5
  end

  test "has many tasks" do
    project = projects(:user_one_project)
    assert_respond_to project, :tasks
  end

  test "has many labels" do
    project = projects(:user_one_project)
    assert_respond_to project, :labels
  end

  test "has many project_keys" do
    project = projects(:user_one_project)
    assert_respond_to project, :project_keys
  end

  test "has many activity_logs" do
    project = projects(:user_one_project)
    assert_respond_to project, :activity_logs
  end

  # -- after_create callbacks --

  test "creates 5 default board_columns after project creation" do
    project = Project.create!(name: "New Project", user: users(:regular))
    assert_equal 5, project.board_columns.count
  end

  test "default board_columns have correct names in order" do
    project = Project.create!(name: "Named Columns Project", user: users(:regular))
    names = project.board_columns.order(:position).pluck(:name)
    assert_equal %w[Backlog Todo In\ Progress Review Done], names
  end

  test "default board_columns have positions 0 through 4" do
    project = Project.create!(name: "Positioned Columns Project", user: users(:regular))
    positions = project.board_columns.order(:position).pluck(:position)
    assert_equal [0, 1, 2, 3, 4], positions
  end

  test "creates 1 project_key after project creation" do
    project = Project.create!(name: "Keyed Project", user: users(:regular))
    assert_equal 1, project.project_keys.count
  end

  test "default project_key is named Default and is active" do
    project = Project.create!(name: "Default Key Project", user: users(:regular))
    key = project.project_keys.first
    assert_equal "Default", key.name
    assert key.active?
  end

  # -- Dependent destroy --

  test "destroys board_columns when project is destroyed" do
    project = Project.create!(name: "Destroyable Project", user: users(:regular))
    column_ids = project.board_columns.pluck(:id)
    project.destroy
    assert_empty BoardColumn.where(id: column_ids)
  end

  test "destroys project_keys when project is destroyed" do
    project = Project.create!(name: "Key Destroyable Project", user: users(:regular))
    key_ids = project.project_keys.pluck(:id)
    project.destroy
    assert_empty ProjectKey.where(id: key_ids)
  end
end
