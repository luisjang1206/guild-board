require "test_helper"

class TaskCardComponentTest < ViewComponent::TestCase
  # active_task: priority low(0), creator_type "user"
  #   labels:     frontend (#3B82F6)
  #   checklists: task_checklist_1 (completed: false), task_checklist_2 (completed: true)
  #   comments:   user_comment, agent_comment (2 total)
  #
  # deleted_task:       priority medium(1), creator_type "user", no labels/checklists/comments
  # high_priority_task: priority high(2),   creator_type "user", no labels/checklists/comments
  # agent_task:         priority low(0),    creator_type "agent", no labels/checklists/comments

  # ---------------------------------------------------------------------------
  # Title
  # ---------------------------------------------------------------------------

  test "renders task title" do
    task = tasks(:active_task)
    render_inline(TaskCardComponent.new(task: task))
    assert_text task.title
  end

  # ---------------------------------------------------------------------------
  # DOM id and data attribute
  # ---------------------------------------------------------------------------

  test "renders wrapper div with correct dom id" do
    task = tasks(:active_task)
    render_inline(TaskCardComponent.new(task: task))
    assert_selector "div#task_#{task.id}"
  end

  test "renders wrapper div with correct data-task-id attribute" do
    task = tasks(:active_task)
    render_inline(TaskCardComponent.new(task: task))
    assert_selector "div[data-task-id='#{task.id}']"
  end

  # ---------------------------------------------------------------------------
  # Priority badge variant
  # ---------------------------------------------------------------------------

  test "renders info badge for low priority" do
    task = tasks(:active_task) # priority: low
    render_inline(TaskCardComponent.new(task: task))
    # BadgeComponent neo info variant uses bg-blue-200
    assert_selector "span.bg-blue-200"
  end

  test "renders warning badge for medium priority" do
    task = tasks(:deleted_task) # priority: medium
    render_inline(TaskCardComponent.new(task: task))
    # BadgeComponent neo warning variant uses bg-yellow-200
    assert_selector "span.bg-yellow-200"
  end

  test "renders error badge for high priority" do
    task = tasks(:high_priority_task) # priority: high
    render_inline(TaskCardComponent.new(task: task))
    # BadgeComponent neo error variant uses bg-red-200
    assert_selector "span.bg-red-200"
  end

  # ---------------------------------------------------------------------------
  # Priority label upcase
  # ---------------------------------------------------------------------------

  test "displays priority string in uppercase" do
    task = tasks(:active_task) # priority: low
    render_inline(TaskCardComponent.new(task: task))
    assert_text "LOW"
  end

  test "displays medium priority in uppercase" do
    task = tasks(:deleted_task) # priority: medium
    render_inline(TaskCardComponent.new(task: task))
    assert_text "MEDIUM"
  end

  test "displays high priority in uppercase" do
    task = tasks(:high_priority_task) # priority: high
    render_inline(TaskCardComponent.new(task: task))
    assert_text "HIGH"
  end

  # ---------------------------------------------------------------------------
  # Label color dots
  # ---------------------------------------------------------------------------

  test "renders label color dot when task has labels" do
    task = tasks(:active_task) # has frontend label (#3B82F6)
    render_inline(TaskCardComponent.new(task: task))
    assert_selector "span[style*='background-color: #3B82F6']"
  end

  test "does not render label dots when task has no labels" do
    task = tasks(:high_priority_task) # no labels
    render_inline(TaskCardComponent.new(task: task))
    assert_no_selector "span[style*='background-color']"
  end

  # ---------------------------------------------------------------------------
  # Checklist progress
  # ---------------------------------------------------------------------------

  test "renders checklist progress when task has checklists" do
    task = tasks(:active_task) # 2 checklists, 1 completed
    render_inline(TaskCardComponent.new(task: task))
    # Expects "1/2" text and descriptive aria-label
    assert_text "1/2"
    assert_selector "[aria-label='Checklist: 1 of 2 completed']"
  end

  test "does not render checklist progress when task has no checklists" do
    task = tasks(:high_priority_task) # no checklists
    render_inline(TaskCardComponent.new(task: task))
    assert_no_selector "[aria-label*='Checklist']"
  end

  # ---------------------------------------------------------------------------
  # Comment count
  # ---------------------------------------------------------------------------

  test "renders comment count when task has comments" do
    task = tasks(:active_task) # 2 comments
    render_inline(TaskCardComponent.new(task: task))
    assert_text "2"
    assert_selector "[aria-label='2 comments']"
  end

  test "does not render comment count when task has no comments" do
    task = tasks(:high_priority_task) # no comments
    render_inline(TaskCardComponent.new(task: task))
    assert_no_selector "[aria-label*='comments']"
  end

  # ---------------------------------------------------------------------------
  # Creator icon
  # ---------------------------------------------------------------------------

  test "renders person SVG icon for user creator" do
    task = tasks(:active_task) # creator_type: "user"
    render_inline(TaskCardComponent.new(task: task))
    assert_selector "[aria-label='Created by user']"
  end

  test "renders robot SVG icon for agent creator" do
    task = tasks(:agent_task) # creator_type: "agent"
    render_inline(TaskCardComponent.new(task: task))
    assert_selector "[aria-label='Created by agent']"
  end
end
