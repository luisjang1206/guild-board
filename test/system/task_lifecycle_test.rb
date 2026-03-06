# frozen_string_literal: true

require "application_system_test_case"

# Korean locale string reference used in this test:
#
#   tasks.new.title           → "새 태스크"
#   tasks.form.title_label    → "제목"
#   tasks.form.submit_create  → "태스크 생성"
#   tasks.form.submit_update  → "태스크 수정"
#   tasks.confirm_delete      → "이 태스크를 삭제하시겠습니까?"
#   defaults.buttons.delete   → "삭제"
#
#   checklists.form.add       → "추가"
#   aria-label "Mark as complete" / "Mark as incomplete" (English — hardcoded in partial)
#
#   comments.form.submit      → "댓글 작성"
#
#   activity_log.title        → "활동 타임라인"
#   activity_log.actions.task_created → "태스크를 생성했습니다"
#   activity_log.actions.task_updated → "태스크를 수정했습니다"
#   activity_log.actions.comment_added → "댓글을 추가했습니다"
#
# Fixtures used:
#   users(:regular)          → email: user@example.com, password: password123
#   projects(:user_one_project)
#
# Task creation flow notes:
#   - The new task form is inside turbo_frame "modal".
#   - TasksController#create redirects to project_board_path after save.
#   - The Task model fires broadcast_append_later_to via ActionCable (async adapter
#     in test env), but the async adapter does not reliably deliver broadcasts to
#     the headless Chrome process in the same test run.
#   - To work around this, after submitting the create form we call
#     `page.refresh` to trigger a full page reload from the DB. This is the
#     standard pattern for Rails system tests that use ActionCable broadcasts.
#
# create_lifecycle_task leaves the browser on the refreshed board page with the
# new task card visible. Subsequent test steps call click_on TASK_TITLE directly.
class TaskLifecycleTest < ApplicationSystemTestCase
  TASK_TITLE      = "Lifecycle Test Task"
  UPDATED_TITLE   = "Updated Lifecycle Task"
  CHECKLIST_ITEM  = "Write the test"
  COMMENT_CONTENT = "This is a lifecycle comment"

  setup do
    @user    = users(:regular)
    @project = projects(:user_one_project)

    sign_in_via_ui(email: "user@example.com", password: "password123")
  end

  # ---------------------------------------------------------------------------
  # 1. Create a task via the board modal
  # ---------------------------------------------------------------------------

  test "user can create a task from the board" do
    visit project_board_path(@project)

    find("a[aria-label*='Backlog']").click
    assert_text "새 태스크"

    within("[role='dialog']") do
      fill_in "제목", with: TASK_TITLE
      fill_in "설명", with: "A task for the lifecycle test"
      select "보통", from: "우선순위"
      click_on "태스크 생성"
    end

    # After redirect the modal is gone; reload to pick up DB state
    assert_no_text "새 태스크", wait: 5
    page.refresh
    assert_text TASK_TITLE
  end

  # ---------------------------------------------------------------------------
  # 2. Add a checklist item from the task detail modal
  # ---------------------------------------------------------------------------

  test "user can add a checklist item to a task" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      fill_in "checklist[content]", with: CHECKLIST_ITEM
      click_on "추가"

      assert_text CHECKLIST_ITEM, wait: 5
    end
  end

  # ---------------------------------------------------------------------------
  # 3. Toggle a checklist item (mark complete / incomplete)
  # ---------------------------------------------------------------------------

  test "user can toggle a checklist item between complete and incomplete" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      # Add the checklist item first
      fill_in "checklist[content]", with: CHECKLIST_ITEM
      click_on "추가"
      assert_text CHECKLIST_ITEM, wait: 5

      # The toggle button aria-label is "Mark as complete" when item is incomplete
      find("[aria-label='Mark as complete']").click

      # After toggling, the button flips to "Mark as incomplete"
      assert_selector "[aria-label='Mark as incomplete']", wait: 5
    end
  end

  # ---------------------------------------------------------------------------
  # 4. Add a comment from the task detail modal
  # ---------------------------------------------------------------------------

  test "user can add a comment to a task" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      fill_in "comment[content]", with: COMMENT_CONTENT
      click_on "댓글 작성"

      assert_text COMMENT_CONTENT, wait: 5
    end
  end

  # ---------------------------------------------------------------------------
  # 5. Activity log shows task_created entry after task creation
  # ---------------------------------------------------------------------------

  test "activity log shows task_created entry after creating a task" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    # The activity log section sits at the bottom of the modal body.
    # Scroll the dialog to the bottom so the section is in the viewport
    # before asserting its text content.
    dialog = find("[role='dialog']")
    dialog.scroll_to :bottom

    within(dialog) do
      assert_text "활동 타임라인"
      assert_text "태스크를 생성했습니다"
    end
  end

  # ---------------------------------------------------------------------------
  # 6. Activity log shows comment_added entry after adding a comment
  # ---------------------------------------------------------------------------

  test "activity log shows comment_added entry after posting a comment" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      fill_in "comment[content]", with: COMMENT_CONTENT
      click_on "댓글 작성"

      assert_text COMMENT_CONTENT, wait: 5
    end

    dialog = find("[role='dialog']")
    dialog.scroll_to :bottom

    within(dialog) do
      assert_text "댓글을 추가했습니다", wait: 5
    end
  end

  # ---------------------------------------------------------------------------
  # 7. Edit a task (title and priority) from the detail modal
  # ---------------------------------------------------------------------------

  test "user can edit a task title and priority from the detail modal" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      click_on "태스크 수정"
    end

    assert_selector "[role='dialog'] h2", text: "태스크 수정"

    within("[role='dialog']") do
      find_field("제목").fill_in with: UPDATED_TITLE
      select "높음", from: "우선순위"
      find("input[type='submit'][value='태스크 수정']").click
    end

    assert_no_selector "[role='dialog']", wait: 5
    # Reload the board to pick up the updated card from the DB
    page.refresh
    assert_text UPDATED_TITLE
    assert_no_text TASK_TITLE
  end

  # ---------------------------------------------------------------------------
  # 8. Activity log records task_updated after editing
  # ---------------------------------------------------------------------------

  test "activity log records task_updated after editing a task" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      click_on "태스크 수정"
    end

    assert_selector "[role='dialog'] h2", text: "태스크 수정"

    within("[role='dialog']") do
      find_field("제목").fill_in with: UPDATED_TITLE
      find("input[type='submit'][value='태스크 수정']").click
    end

    assert_no_selector "[role='dialog']", wait: 5
    page.refresh
    assert_text UPDATED_TITLE

    click_on UPDATED_TITLE
    assert_selector "[role='dialog']"

    dialog = find("[role='dialog']")
    dialog.scroll_to :bottom

    within(dialog) do
      assert_text "활동 타임라인"
      assert_text "태스크를 수정했습니다"
    end
  end

  # ---------------------------------------------------------------------------
  # 9. Delete a task from the detail modal
  # ---------------------------------------------------------------------------

  test "user can delete a task from the detail modal" do
    create_lifecycle_task

    click_on TASK_TITLE
    assert_selector "[role='dialog']"

    accept_confirm do
      within("[role='dialog']") do
        click_on "삭제"
      end
    end

    # TasksController#destroy redirects to board; task card is removed via broadcast.
    # Reload to confirm the DB-level soft-delete is reflected.
    assert_no_selector "[role='dialog']", wait: 5
    page.refresh
    assert_no_text TASK_TITLE
  end

  private

  # Creates a fresh task via the UI and leaves the browser on the board page
  # with the new task card visible. After submitting the form, calls page.refresh
  # to load board state from the DB (bypassing unreliable ActionCable async
  # broadcast delivery in the test environment).
  def create_lifecycle_task
    visit project_board_path(@project)

    find("a[aria-label*='Backlog']").click
    assert_text "새 태스크"

    within("[role='dialog']") do
      fill_in "제목", with: TASK_TITLE
      click_on "태스크 생성"
    end

    # Wait for the create modal to close: Turbo replaces the "modal" frame
    # with an empty tag from boards/show.html.erb after the redirect.
    assert_no_text "새 태스크", wait: 5
    page.refresh
    assert_text TASK_TITLE
  end
end
