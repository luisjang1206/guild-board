require "test_helper"

class BoardColumnTest < ActiveSupport::TestCase
  setup do
    @column = board_columns(:todo)
  end

  # -- Validations --

  test "valid with name and project" do
    column = BoardColumn.new(name: "In Review", project: projects(:user_one_project))
    assert column.valid?
  end

  test "invalid without name" do
    column = BoardColumn.new(project: projects(:user_one_project))
    assert_not column.valid?
    assert column.errors[:name].any?
  end

  test "invalid with blank name" do
    column = BoardColumn.new(name: "  ", project: projects(:user_one_project))
    assert_not column.valid?
    assert column.errors[:name].any?
  end

  test "invalid without project" do
    column = BoardColumn.new(name: "Orphaned Column")
    assert_not column.valid?
    assert column.errors[:project].any?
  end

  # -- Associations --

  test "belongs to project" do
    assert_equal projects(:user_one_project), @column.project
  end

  test "has many tasks" do
    assert_respond_to @column, :tasks
  end

  test "tasks are destroyed with board_column" do
    # Use a fresh column with a fresh task (no activity_log FK) to avoid FK violation
    project = projects(:user_two_project)
    column = BoardColumn.create!(name: "Temp Column", project: project)
    Task.create!(
      title: "Temp Task",
      creator_type: "user",
      creator_id: "1",
      project: project,
      board_column: column
    )
    assert_difference "Task.count", -1 do
      column.destroy
    end
  end

  # -- Positionable --

  test "includes Positionable" do
    assert BoardColumn.ancestors.include?(Positionable)
  end

  test "auto-assigns next position on create within same project" do
    project = projects(:user_one_project)
    # Existing columns are positions 0-4, so next should be 5
    max_existing = project.board_columns.maximum(:position)
    new_column = BoardColumn.create!(name: "Staging", project: project)
    assert_equal max_existing + 1, new_column.position
  end

  test "auto-assigns position 0 for first column in a new project" do
    project = Project.create!(name: "Fresh Project For Column", user: users(:admin))
    # after_create creates 5 columns; grab a fresh project with no columns to test
    # We test by creating a new project and checking the first column gets position 0
    first_column = project.board_columns.order(:position).first
    assert_equal 0, first_column.position
  end

  test "positions are scoped per project" do
    other_project = projects(:user_two_project)
    column_in_other = BoardColumn.create!(name: "Other Backlog", project: other_project)
    # Should start at 0 for a project with no pre-existing fixture columns
    assert_equal 0, column_in_other.position
  end
end
