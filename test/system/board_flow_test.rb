# frozen_string_literal: true

require "application_system_test_case"

# Korean locale string reference (config/locales/models/task.ko.yml):
#   tasks.new.title          → "새 태스크"
#   tasks.edit.title         → "태스크 수정"
#   tasks.form.title_label   → "제목"
#   tasks.form.description_label → "설명"
#   tasks.form.priority_label → "우선순위"
#   tasks.form.priority_low  → "낮음"
#   tasks.form.priority_high → "높음"
#   tasks.form.submit_create → "태스크 생성"
#   tasks.form.submit_update → "태스크 수정"  (same as edit title — scope carefully)
#
# Korean locale strings from defaults/ko.yml:
#   defaults.buttons.cancel  → "취소"
#   defaults.buttons.delete  → "삭제"
#
# Korean locale string from show view (tasks.show.*):
#   Edit Task link on show modal → "태스크 수정"
#
# Board column names are rendered uppercase via CSS — assert with uppercase.
# Task title in show modal header is also uppercase via CSS.
class BoardFlowTest < ApplicationSystemTestCase
  setup do
    @user    = users(:regular)
    @project = projects(:user_one_project)
    @task    = tasks(:active_task)

    sign_in_via_ui(email: "user@example.com", password: "password123")
  end

  # ---------------------------------------------------------------------------
  # 1. View board
  # ---------------------------------------------------------------------------

  test "authenticated user can view the board with columns and tasks" do
    visit project_board_path(@project)

    # Project name rendered uppercase via CSS
    assert_text "USER ONE PROJECT"

    # All five fixture columns visible (uppercase)
    assert_text "BACKLOG"
    assert_text "TODO"
    assert_text "IN PROGRESS"
    assert_text "REVIEW"
    assert_text "DONE"

    # Active task card present
    assert_text "Active Task"
  end

  # ---------------------------------------------------------------------------
  # 2. Create task
  # ---------------------------------------------------------------------------

  test "user can create a new task via the column add-task button" do
    visit project_board_path(@project)

    # The "+" link on the Backlog column has aria-label "Backlog에 태스크 추가"
    # (board_column.add_task in ko locale). The delete-column button also contains
    # "Backlog" in its aria-label, so scope to an anchor to avoid ambiguity.
    find("a[aria-label*='Backlog']").click

    # Modal heading: t("tasks.new.title") → "새 태스크"
    assert_text "새 태스크"

    # The filter bar on the board also has a "우선순위" select, so scope all
    # form interactions within the dialog to avoid ambiguity.
    within("[role='dialog']") do
      # Form labels are Korean; fill_in matches <label> text.
      fill_in "제목", with: "My System Test Task"
      fill_in "설명", with: "Created by a system test"

      # Priority select options are Korean: "낮음" / "보통" / "높음"
      select "높음", from: "우선순위"

      # Submit: t("tasks.form.submit_create") → "태스크 생성"
      click_on "태스크 생성"
    end

    # Modal dismissed; new card visible on the board
    assert_no_text "새 태스크"
    assert_text "My System Test Task"
  end

  # ---------------------------------------------------------------------------
  # 3. View task details
  # ---------------------------------------------------------------------------

  test "user can open a task card to view its details in a modal" do
    visit project_board_path(@project)

    # Click the task title link (data-turbo-frame="modal")
    click_on "Active Task"

    # Wait for the show modal to open
    assert_selector "[role='dialog']"

    within("[role='dialog']") do
      # Column name shown uppercase above the task title
      assert_text "TODO"
      # Task title rendered uppercase in the modal header
      assert_text "ACTIVE TASK"
      # Priority badge: @task.priority.upcase → "LOW"
      assert_text "LOW"
      # Description from fixture
      assert_text "An active test task"
    end
  end

  # ---------------------------------------------------------------------------
  # 4. Edit task
  # ---------------------------------------------------------------------------

  test "user can edit a task from the detail modal" do
    visit project_board_path(@project)

    # Open the show modal
    click_on "Active Task"
    assert_selector "[role='dialog']"

    # The "Edit Task" link in the show modal footer is labelled
    # t("tasks.edit.title") → "태스크 수정" in ko locale.
    # Scope within the dialog to target that specific link.
    within("[role='dialog']") do
      click_on "태스크 수정"
    end

    # Edit modal replaces the show modal — its heading is also "태스크 수정"
    # (same i18n key). Wait for the edit form to be present by checking for the
    # submit button, which is "태스크 수정" (submit_update).
    assert_selector "[role='dialog'] h2", text: "태스크 수정"

    # Clear and update the title. The label text is t("tasks.form.title_label") → "제목"
    find_field("제목").fill_in with: "Updated Task Title"

    # Submit: t("tasks.form.submit_update") → "태스크 수정"
    # Scope to the submit input to avoid clicking the heading link
    find("input[type='submit'][value='태스크 수정']").click

    # Modal dismissed; updated card visible on the board
    assert_no_selector "[role='dialog']"
    assert_text "Updated Task Title"
    assert_no_text "Active Task"
  end

  # ---------------------------------------------------------------------------
  # 5. Delete task
  # ---------------------------------------------------------------------------

  test "user can delete a task from the detail modal" do
    visit project_board_path(@project)

    # Open the show modal
    click_on "Active Task"
    assert_selector "[role='dialog']"

    # Delete button: t("defaults.buttons.delete") → "삭제" in ko locale.
    # The button_to in show.html.erb uses turbo_confirm which triggers a
    # browser native confirm dialog.
    accept_confirm do
      within("[role='dialog']") do
        click_on "삭제"
      end
    end

    # Modal dismissed; task card removed from board
    assert_no_selector "[role='dialog']"
    assert_no_text "Active Task"
  end
end
