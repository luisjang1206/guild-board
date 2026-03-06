require "test_helper"

# Tests for the Positionable concern using BoardColumn as the concrete model.
# BoardColumn uses `positionable scope: :project_id`.
class PositionableTest < ActiveSupport::TestCase
  # Use a dedicated fresh project so tests don't collide with fixture columns
  # on user_one_project (positions 0-4 already occupied).
  setup do
    # user_two_project has no fixture board_columns, giving us a clean slate.
    @project = projects(:user_two_project)
  end

  # -- Auto-assignment of initial position --

  test "first record in a scope gets position 0" do
    column = BoardColumn.create!(name: "First", project: @project)
    assert_equal 0, column.position
  end

  test "second record gets position 1" do
    BoardColumn.create!(name: "Alpha", project: @project)
    column = BoardColumn.create!(name: "Beta", project: @project)
    assert_equal 1, column.position
  end

  test "each new record increments position by 1" do
    3.times { |i| BoardColumn.create!(name: "Col #{i}", project: @project) }
    fourth = BoardColumn.create!(name: "Fourth", project: @project)
    assert_equal 3, fourth.position
  end

  test "positions are independent across scopes (projects)" do
    # user_one_project already has 5 columns (positions 0-4)
    column_in_other = BoardColumn.create!(name: "Isolated", project: @project)
    assert_equal 0, column_in_other.position
  end

  # -- move_to_position: moving forward (higher position) --

  test "move_to_position does nothing when moving to current position" do
    col_a = BoardColumn.create!(name: "A", project: @project)  # pos 0
    col_b = BoardColumn.create!(name: "B", project: @project)  # pos 1
    col_b.move_to_position(1)
    assert_equal 1, col_b.reload.position
    assert_equal 0, col_a.reload.position
  end

  test "move_to_position forward shifts intermediate items back by 1" do
    col_a = BoardColumn.create!(name: "A", project: @project)  # pos 0
    col_b = BoardColumn.create!(name: "B", project: @project)  # pos 1
    col_c = BoardColumn.create!(name: "C", project: @project)  # pos 2

    # Move A from 0 to 2
    col_a.move_to_position(2)

    assert_equal 2, col_a.reload.position
    assert_equal 0, col_b.reload.position
    assert_equal 1, col_c.reload.position
  end

  # -- move_to_position: moving backward (lower position) --

  test "move_to_position backward shifts intermediate items forward by 1" do
    col_a = BoardColumn.create!(name: "A", project: @project)  # pos 0
    col_b = BoardColumn.create!(name: "B", project: @project)  # pos 1
    col_c = BoardColumn.create!(name: "C", project: @project)  # pos 2

    # Move C from 2 to 0
    col_c.move_to_position(0)

    assert_equal 0, col_c.reload.position
    assert_equal 1, col_a.reload.position
    assert_equal 2, col_b.reload.position
  end

  test "move_to_position one step backward shifts only the adjacent item" do
    col_a = BoardColumn.create!(name: "A", project: @project)  # pos 0
    col_b = BoardColumn.create!(name: "B", project: @project)  # pos 1
    col_c = BoardColumn.create!(name: "C", project: @project)  # pos 2

    # Move C from 2 to 1
    col_c.move_to_position(1)

    assert_equal 1, col_c.reload.position
    assert_equal 2, col_b.reload.position
    assert_equal 0, col_a.reload.position
  end

  test "move_to_position one step forward shifts only the adjacent item" do
    col_a = BoardColumn.create!(name: "A", project: @project)  # pos 0
    col_b = BoardColumn.create!(name: "B", project: @project)  # pos 1
    col_c = BoardColumn.create!(name: "C", project: @project)  # pos 2

    # Move A from 0 to 1
    col_a.move_to_position(1)

    assert_equal 1, col_a.reload.position
    assert_equal 0, col_b.reload.position
    assert_equal 2, col_c.reload.position
  end

  # -- Scope isolation for move_to_position --

  test "move_to_position does not affect columns in a different project" do
    # user_one_project has fixture columns at positions 0-4
    fixture_col = board_columns(:backlog)  # position 0 on user_one_project
    fixture_position_before = fixture_col.position

    col_a = BoardColumn.create!(name: "A", project: @project)  # pos 0
    col_b = BoardColumn.create!(name: "B", project: @project)  # pos 1
    col_a.move_to_position(1)

    assert_equal fixture_position_before, fixture_col.reload.position
  end
end
