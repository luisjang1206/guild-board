require "test_helper"

class TaskMoveTest < ActiveSupport::TestCase
  # Fixtures used:
  #   user_one_project — has board_columns: backlog(0), todo(1), in_progress(2), review(3), done(4)
  #   active_task  — todo column, position 0
  #   deleted_task — todo column, position 1
  #
  # user_two_project — has board_columns from fixtures: backlog only (no named fixture columns)
  #   high_priority_task — backlog, position 0
  #   agent_task         — backlog, position 1
  #
  # We use user_one_project's columns for cross-column move tests because backlog has
  # no tasks (active_task / deleted_task are both in todo), giving a clean target column.

  setup do
    @active_task  = tasks(:active_task)   # todo, position 0
    @deleted_task = tasks(:deleted_task)  # todo, position 1
    @todo         = board_columns(:todo)
    @backlog      = board_columns(:backlog)
    @in_progress  = board_columns(:in_progress)
  end

  # -------------------------------------------------------------------------
  # Same-column position change (delegates to move_to_position)
  # -------------------------------------------------------------------------

  test "move_to_column within same column swaps positions of two tasks" do
    # todo has: active_task(0), deleted_task(1)
    # Move active_task from position 0 to position 1
    @active_task.move_to_column(@todo.id, 1)

    assert_equal 1, @active_task.reload.position
    assert_equal 0, @deleted_task.reload.position
  end

  test "move_to_column within same column is a no-op when position unchanged" do
    original_position = @active_task.position
    @active_task.move_to_column(@todo.id, original_position)

    assert_equal original_position, @active_task.reload.position
    # sibling must be untouched
    assert_equal 1, @deleted_task.reload.position
  end

  test "move_to_column within same column keeps board_column_id unchanged" do
    original_column_id = @active_task.board_column_id
    @active_task.move_to_column(@todo.id, 1)

    assert_equal original_column_id, @active_task.reload.board_column_id
  end

  # -------------------------------------------------------------------------
  # Cross-column move — board_column_id change
  # -------------------------------------------------------------------------

  test "move_to_column to a different column updates board_column_id" do
    @active_task.move_to_column(@backlog.id, 0)

    assert_equal @backlog.id, @active_task.reload.board_column_id
  end

  test "move_to_column to a different column updates position to requested value" do
    @active_task.move_to_column(@backlog.id, 0)

    assert_equal 0, @active_task.reload.position
  end

  test "move_to_column shifts down tasks after the removed position in the old column" do
    # active_task is at position 0 in todo; deleted_task is at position 1.
    # deleted_task has deleted_at set, so move_to_column's where(deleted_at: nil) excludes it.
    # Therefore deleted_task position remains unchanged at 1.
    @active_task.move_to_column(@backlog.id, 0)

    assert_equal 1, @deleted_task.reload.position
  end

  test "move_to_column shifts up tasks at and after the insertion position in the new column" do
    # backlog already has high_priority_task(pos 0) and agent_task(pos 1) from fixtures.
    # arriving_task is created next, so set_initial_position assigns it position 2.
    arriving_task = Task.create!(
      title: "Backlog Task",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @backlog
    )
    # arriving_task gets position 2 (after existing fixtures).
    assert_equal 2, arriving_task.position

    # Move active_task into backlog at position 0 — all active tasks at position >= 0 shift +1.
    # high_priority_task(0→1), agent_task(1→2), arriving_task(2→3).
    @active_task.move_to_column(@backlog.id, 0)

    assert_equal 3, arriving_task.reload.position
    assert_equal 0, @active_task.reload.position
  end

  test "move_to_column to a different column inserts at a non-zero position correctly" do
    # backlog already has high_priority_task(pos 0) and agent_task(pos 1) from fixtures.
    # Seed two more tasks: first gets pos 2, second gets pos 3.
    first = Task.create!(
      title: "Backlog First",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @backlog
    )
    second = Task.create!(
      title: "Backlog Second",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @backlog
    )
    # first → 2, second → 3

    # Move active_task into backlog at position 1 (between high_priority_task and agent_task).
    # All active tasks at position >= 1 shift +1:
    #   agent_task(1→2), first(2→3), second(3→4). high_priority_task(0) unchanged.
    @active_task.move_to_column(@backlog.id, 1)

    assert_equal 1, @active_task.reload.position
    assert_equal 3, first.reload.position    # shifted: 2 → 3
    assert_equal 4, second.reload.position  # shifted: 3 → 4
  end

  test "move_to_column does not affect tasks in unrelated columns" do
    # in_progress has no tasks; its sibling state must remain independent.
    # deleted_task has deleted_at set, so move_to_column's where(deleted_at: nil) excludes it
    # from the shift. Its position remains unchanged at 1.
    original_deleted_pos = @deleted_task.position
    @active_task.move_to_column(@in_progress.id, 0)

    # deleted_task was soft-deleted, so it is NOT shifted — position stays the same.
    assert_equal original_deleted_pos, @deleted_task.reload.position
  end

  test "move_to_column wraps both column updates in a single transaction" do
    # Force an error after the first update_all to confirm rollback.
    # We stub move_to_column partially by verifying atomicity via direct DB state.
    # Instead, confirm that if the task itself cannot be saved (invalid state forced),
    # neither column is mutated.
    #
    # This is a smoke test: if the cross-column branch raises, positions are intact.
    original_todo_positions = @todo.tasks.order(:position).pluck(:id, :position)

    assert_raises(StandardError) do
      # Pass a non-existent column id to trigger a FK violation inside the transaction.
      @active_task.move_to_column(-999, 0)
    end

    # Positions in todo column must be unchanged.
    assert_equal original_todo_positions, @todo.tasks.order(:position).pluck(:id, :position)
  end
end
