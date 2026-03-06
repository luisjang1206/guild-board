# frozen_string_literal: true

require "application_system_test_case"

# Real-time synchronisation tests: two independent browser sessions (simulating
# two tabs / two devices logged in as the same user) subscribe to the same board
# stream and verify that an action taken in session A propagates automatically
# to session B via Action Cable + Turbo Streams.
#
# Why same user in both sessions?
#   ProjectPolicy#show? restricts board access to the project owner.
#   Using two sessions as the same owner avoids 403 errors while still
#   exercising the real-time multi-session delivery path.
#
# Why use task update instead of task create for the broadcast trigger?
#   TasksController#create uses a redirect response which has known issues
#   closing the Turbo Frame modal in the current codebase.
#   TasksController#update responds with `turbo_stream` (update.turbo_stream.erb),
#   which both closes the modal via `turbo_stream.update "modal"` AND fires
#   Task#after_update_commit → broadcast_replace_later_to.  This gives us a
#   clean, reliable trigger for the real-time sync assertion.
#
# Why create the task via AR in setup instead of using fixture tasks?
#   Fixture tasks (e.g. active_task) have associated activity_log fixtures
#   that reference them.  The show view renders activity_logs; the
#   has_many :activity_logs association on Task is a pending (unstaged)
#   model change in this branch.  To keep the test self-contained and
#   immune to that model state, we create a fresh task inline in setup.
#
# Infrastructure notes:
#   - config/cable.yml test env uses the `async` adapter so that the
#     Action Cable server runs in-process (a background thread) and can
#     deliver broadcasts to both browser sessions without an external broker.
#   - Task.after_update_commit fires broadcast_replace_later_to which enqueues
#     Turbo::Streams::ActionBroadcastJob.  We switch ActiveJob::Base's adapter
#     to :inline so the job executes synchronously, ensuring the cable server
#     receives and delivers the broadcast before Capybara's wait timeout.
#   - Turbo::SystemTestHelper (auto-included by turbo-rails into
#     ActionDispatch::SystemTestCase) provides connect_turbo_cable_stream_sources,
#     which blocks until every <turbo-cable-stream-source> element reports
#     connected="", confirming the Action Cable subscription is live.
#   - Capybara.using_session switches the active browser window so subsequent
#     DSL calls (visit, fill_in, assert_text …) target that named session.
#
# Korean locale strings used:
#   tasks.edit.title          → "태스크 수정"
#   tasks.form.title_label    → "제목"
#   tasks.form.submit_update  → "태스크 수정"
#
# Fixtures:
#   users(:regular)             → email: user@example.com, password: password123
#   projects(:user_one_project) → owned by :regular
#   board_columns(:backlog)     → first column in user_one_project
class RealtimeSyncTest < ApplicationSystemTestCase
  SESSION_A = "user_a"
  SESSION_B = "user_b"

  ORIGINAL_TITLE = "Sync Test Original Task"
  UPDATED_TITLE  = "Sync Test Updated Title"

  setup do
    @project = projects(:user_one_project)
    @column  = board_columns(:backlog)

    # Create a fresh task inline (no fixture activity_logs attached) so the
    # show view does not crash due to the pending has_many :activity_logs
    # association on Task.  The task is visible on the board immediately.
    @task = Task.create!(
      project:      @project,
      board_column: @column,
      title:        ORIGINAL_TITLE,
      description:  "A task for real-time sync testing",
      priority:     :low,
      creator_type: "user",
      creator_id:   users(:regular).id.to_s
    )

    # Switch broadcast jobs to run inline (synchronously) so the cable server
    # receives and delivers the Turbo Stream before Capybara's assertion fires.
    @original_queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline

    # Both sessions authenticate as the project owner (:regular).
    # Sign in SESSION_B first so that SESSION_A's cookie is the last one
    # issued, keeping SESSION_A's authentication valid throughout the test.
    Capybara.using_session(SESSION_B) do
      sign_in_via_ui(email: "user@example.com", password: "password123")
    end

    Capybara.using_session(SESSION_A) do
      sign_in_via_ui(email: "user@example.com", password: "password123")
    end
  end

  teardown do
    # Restore the original queue adapter after each test
    ActiveJob::Base.queue_adapter = @original_queue_adapter

    # Reset Capybara sessions to a clean state
    Capybara.reset_sessions!
  end

  # -----------------------------------------------------------------------
  # Core real-time sync scenario
  # -----------------------------------------------------------------------

  test "task update by user_a appears on user_b's board without a page reload" do
    # Step 1 — both sessions open the board and establish WebSocket connections.
    # connect_turbo_cable_stream_sources waits until every
    # <turbo-cable-stream-source> element reports connected="", confirming
    # the Action Cable subscription is live for that session.
    Capybara.using_session(SESSION_A) do
      visit project_board_path(@project)
      connect_turbo_cable_stream_sources

      # Confirm the fresh task card is visible before proceeding
      assert_text ORIGINAL_TITLE
    end

    Capybara.using_session(SESSION_B) do
      visit project_board_path(@project)
      connect_turbo_cable_stream_sources

      # Confirm the fresh task card is also visible in session B
      assert_text ORIGINAL_TITLE
    end

    # Step 2 — session A opens the task show modal, navigates to edit,
    # changes the title, and submits.  TasksController#update responds with
    # turbo_stream (update.turbo_stream.erb) which:
    #   (a) replaces the task card on the board via `turbo_stream.replace`
    #   (b) clears the modal via `turbo_stream.update "modal"`
    #   (c) triggers Task#after_update_commit → broadcast_replace_later_to
    Capybara.using_session(SESSION_A) do
      click_on ORIGINAL_TITLE
      assert_selector "[role='dialog']", wait: 5

      within("[role='dialog']") do
        click_on "태스크 수정"
      end

      assert_selector "[role='dialog'] h2", text: "태스크 수정", wait: 5

      within("[role='dialog']") do
        find_field("제목").fill_in with: UPDATED_TITLE
        find("input[type='submit'][value='태스크 수정']").click
      end

      # The turbo_stream update closes the modal and replaces the task card
      assert_no_selector "[role='dialog']"
      assert_text UPDATED_TITLE
      assert_no_text ORIGINAL_TITLE
    end

    # Step 3 — session B should receive the Turbo Stream broadcast and display
    # the updated task card without any manual page reload.
    Capybara.using_session(SESSION_B) do
      assert_text UPDATED_TITLE, wait: 5
      assert_no_text ORIGINAL_TITLE
    end
  end
end
