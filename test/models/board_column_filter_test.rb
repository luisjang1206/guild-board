require "test_helper"

class BoardColumnFilterTest < ActiveSupport::TestCase
  setup do
    @todo    = board_columns(:todo)
    # Use a column that has no fixture tasks (in_progress has none)
    @empty_column = board_columns(:in_progress)
    @task    = tasks(:active_task)   # todo, position 0, priority low, creator_type user
  end

  # -- No filters --

  test "active_tasks returns only non-deleted tasks" do
    result = @todo.active_tasks
    assert_includes result, tasks(:active_task)
    assert_not_includes result, tasks(:deleted_task)
  end

  test "active_tasks returns empty array for column with no tasks" do
    # in_progress has no fixture tasks
    assert_empty @empty_column.active_tasks
  end

  # -- Priority filter --

  test "active_tasks filters by priority returning matching tasks" do
    # active_task has priority: 0 (low); deleted_task has priority: 1 (medium) but is deleted.
    # Add a medium-priority active task to the todo column for a meaningful assertion.
    medium_task = Task.create!(
      title: "Medium Task",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @todo,
      priority: :medium
    )

    result = @todo.active_tasks(priority: "medium")
    assert_includes result, medium_task
    assert_not_includes result, tasks(:active_task)
  end

  test "active_tasks filters by priority excluding tasks of other priorities" do
    result = @todo.active_tasks(priority: "low")
    assert_includes result, tasks(:active_task)
    # deleted_task is medium priority and also deleted — must not appear
    assert_not_includes result, tasks(:deleted_task)
  end

  test "active_tasks with priority filter returns empty when no active tasks match" do
    # No active tasks in todo with high priority
    result = @todo.active_tasks(priority: "high")
    assert_empty result
  end

  # -- creator_type filter --

  test "active_tasks filters by creator_type user" do
    result = @todo.active_tasks(creator_type: "user")
    assert_includes result, tasks(:active_task)
    result.each { |t| assert_equal "user", t.creator_type }
  end

  test "active_tasks filters by creator_type returns empty when no match" do
    # todo column has no active agent tasks
    result = @todo.active_tasks(creator_type: "agent")
    assert_empty result
  end

  # -- label_id filter --

  test "active_tasks filters by label_id returning tasks with that label" do
    # active_task already has the frontend label via the task_labels fixture
    frontend_label = labels(:frontend)
    result = @todo.active_tasks(label_id: frontend_label.id)
    assert_includes result, tasks(:active_task)
  end

  test "active_tasks label_id filter excludes tasks without that label" do
    # active_task does not have the backend label
    backend_label = labels(:backend)
    result = @todo.active_tasks(label_id: backend_label.id)
    assert_not_includes result, tasks(:active_task)
  end

  test "active_tasks label_id filter accepts string id" do
    # label_id coming from params is a string; to_i conversion in the method handles it
    frontend_label = labels(:frontend)
    result = @todo.active_tasks(label_id: frontend_label.id.to_s)
    assert_includes result, tasks(:active_task)
  end

  test "active_tasks filters by label_id returns empty when no active task has that label" do
    bugfix_label = labels(:bugfix)
    # No fixture task in todo is associated with bugfix
    result = @todo.active_tasks(label_id: bugfix_label.id)
    assert_empty result
  end

  # -- Sorting --

  test "active_tasks results are sorted by position ascending" do
    # Use @empty_column (in_progress) which has no fixture tasks — Positionable
    # assigns positions 0 and 1 sequentially.
    first_task = Task.create!(
      title: "First Task",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @empty_column
    )
    second_task = Task.create!(
      title: "Second Task",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @empty_column
    )

    result = @empty_column.active_tasks
    assert_equal [ first_task, second_task ], result
  end

  test "active_tasks results maintain sort order when filters are applied" do
    medium_first = Task.create!(
      title: "Medium First",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @empty_column,
      priority: :medium
    )
    medium_second = Task.create!(
      title: "Medium Second",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: @empty_column,
      priority: :medium
    )

    result = @empty_column.active_tasks(priority: "medium")
    assert_equal [ medium_first, medium_second ], result
  end
end
