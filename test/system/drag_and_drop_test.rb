# frozen_string_literal: true

require "application_system_test_case"

# Drag-and-drop task movement tests.
#
# SortableJS handles drag events natively, so Capybara's `drag_to` does not
# trigger the library's `onEnd` callback. Instead, these tests simulate the
# same PATCH /projects/:project_id/tasks/:id/move API call that the drag
# controller's `onEnd` handler performs via fetch. After a successful PATCH,
# the server broadcasts two Turbo Stream actions over ActionCable
# (broadcast_remove_to + broadcast_append_to), which are applied by the
# browser's existing `turbo_stream_from @project, :board` subscription.
# Because the system test browser maintains a real WebSocket connection,
# the DOM is updated without a page reload.
#
# Board column fixture layout (user_one_project):
#   backlog (pos 0) — no active tasks initially
#   todo    (pos 1) — active_task (pos 0)
#
# Selectors used:
#   Task card wrapper : #task_<id>                   (task_card_component.html.erb)
#   Column task list  : #board_column_<col_id>_tasks  (kanban_column_component.rb dom_id)
#   Column wrapper    : [data-column-id="<col_id>"]   (kanban_column_component.html.erb)
class DragAndDropTest < ApplicationSystemTestCase
  setup do
    @user    = users(:regular)
    @project = projects(:user_one_project)
    @task    = tasks(:active_task)  # todo column, position 0

    # Resolve fixture board column IDs at test setup time.
    @todo_column    = board_columns(:todo)
    @backlog_column = board_columns(:backlog)

    sign_in_via_ui(email: "user@example.com", password: "password123")
  end

  # ---------------------------------------------------------------------------
  # Helper: simulates the fetch call that drag_controller.js performs in onEnd.
  #
  # The CSRF token and project ID are interpolated into the JS string at the
  # Ruby level so the script is self-contained. This avoids relying on the
  # Selenium `arguments[]` mechanism, which can fail when the executing context
  # is not the page's top-level frame.
  # ---------------------------------------------------------------------------
  def simulate_move(task_id:, board_column_id:, position: 0)
    project_id = @project.id
    js = <<~JS
      (function() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        var token = meta ? meta.getAttribute('content') : '';
        fetch('/projects/#{project_id}/tasks/#{task_id}/move', {
          method: 'PATCH',
          headers: {
            'X-CSRF-Token': token,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ board_column_id: #{board_column_id}, position: #{position} })
        });
      })();
    JS
    # evaluate_script blocks until the IIFE returns (synchronously), which
    # ensures the fetch has been dispatched before Capybara continues.
    evaluate_script(js)
  end

  # ---------------------------------------------------------------------------
  # 1. Move task to a different column
  # ---------------------------------------------------------------------------

  test "task appears in the destination column after being moved via API" do
    visit project_board_path(@project)

    # Verify the task starts in the Todo column task list
    within("#board_column_#{@todo_column.id}_tasks") do
      assert_text "Active Task"
    end

    # The Backlog column should not contain the task yet
    within("#board_column_#{@backlog_column.id}_tasks") do
      assert_no_text "Active Task"
    end

    # Simulate the drag_controller fetch call — move active_task to Backlog
    simulate_move(task_id: @task.id, board_column_id: @backlog_column.id, position: 0)

    # The server broadcasts broadcast_remove_to (removes from Todo) and
    # broadcast_append_to (appends to Backlog) over ActionCable. Wait for
    # the Turbo Stream to apply and the DOM to update.
    within("#board_column_#{@backlog_column.id}_tasks", wait: 5) do
      assert_text "Active Task"
    end

    # The task should no longer appear in the original Todo column task list
    within("#board_column_#{@todo_column.id}_tasks") do
      assert_no_text "Active Task"
    end
  end

  test "task database record reflects the new column after move" do
    visit project_board_path(@project)

    simulate_move(task_id: @task.id, board_column_id: @backlog_column.id, position: 0)

    # Wait for the DOM update to confirm the server processed the request
    within("#board_column_#{@backlog_column.id}_tasks", wait: 5) do
      assert_text "Active Task"
    end

    # Verify persistence in the database
    assert_equal @backlog_column.id, @task.reload.board_column_id
    assert_equal 0, @task.reload.position
  end

  # ---------------------------------------------------------------------------
  # 2. Reorder tasks within the same column
  # ---------------------------------------------------------------------------

  test "two tasks in same column can be reordered" do
    # Create a second active task in the Backlog column so we have two tasks
    # to reorder. Use Backlog (no fixture tasks) to avoid FK conflicts with
    # activity_logs on active_task.
    second_task = @project.tasks.create!(
      title: "Second Backlog Task",
      description: "For reorder test",
      board_column: @backlog_column,
      priority: :low,
      creator_type: "user",
      creator_id: @user.id.to_s
    )

    # Pre-move active_task to Backlog at position 0 directly in the DB so we
    # start the browser session with both tasks already in Backlog. Using a
    # direct DB call avoids making fetch calls before the page is loaded.
    @task.move_to_column(@backlog_column.id, 0)

    visit project_board_path(@project)

    # Both tasks should be visible in Backlog
    within("#board_column_#{@backlog_column.id}_tasks", wait: 5) do
      assert_text "Active Task"
      assert_text "Second Backlog Task"
    end

    # Now reorder via the API: move second_task to position 0 (before active_task)
    simulate_move(task_id: second_task.id, board_column_id: @backlog_column.id, position: 0)

    # Wait for the broadcast to update the DOM
    within("#board_column_#{@backlog_column.id}_tasks", wait: 5) do
      assert_text "Second Backlog Task"
      assert_text "Active Task"
    end

    # Verify position in the database
    assert_equal 0, second_task.reload.position
    assert_equal @backlog_column.id, second_task.reload.board_column_id
  end

  # ---------------------------------------------------------------------------
  # 3. Move task back to original column (round-trip)
  # ---------------------------------------------------------------------------

  test "task can be moved back to its original column" do
    visit project_board_path(@project)

    # Move to Backlog
    simulate_move(task_id: @task.id, board_column_id: @backlog_column.id, position: 0)

    within("#board_column_#{@backlog_column.id}_tasks", wait: 5) do
      assert_text "Active Task"
    end

    # Move back to Todo
    simulate_move(task_id: @task.id, board_column_id: @todo_column.id, position: 0)

    within("#board_column_#{@todo_column.id}_tasks", wait: 5) do
      assert_text "Active Task"
    end

    within("#board_column_#{@backlog_column.id}_tasks") do
      assert_no_text "Active Task"
    end

    assert_equal @todo_column.id, @task.reload.board_column_id
  end

  # ---------------------------------------------------------------------------
  # 4. Board remains functional after a move (other UI interactions work)
  # ---------------------------------------------------------------------------

  test "board interactions remain functional after a drag-and-drop move" do
    visit project_board_path(@project)

    # Move the task to Backlog
    simulate_move(task_id: @task.id, board_column_id: @backlog_column.id, position: 0)

    within("#board_column_#{@backlog_column.id}_tasks", wait: 5) do
      assert_text "Active Task"
    end

    # Verify the task card link is still clickable and opens the show modal
    click_on "Active Task"
    assert_selector "[role='dialog']", wait: 5

    within("[role='dialog']") do
      # The column name shown in the modal header should now be Backlog
      assert_text "BACKLOG"
      assert_text "ACTIVE TASK"
    end
  end
end
