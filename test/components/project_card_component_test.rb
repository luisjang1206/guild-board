require "test_helper"

class ProjectCardComponentTest < ViewComponent::TestCase
  # user_one_project (owner: regular)
  #   board_columns: backlog(0) todo(1) in_progress(2) review(3) done(4)
  #   tasks:  active_task  (todo, pos 0, priority low,    deleted_at: nil)  → counted
  #           deleted_task (todo, pos 1, priority medium, deleted_at: set)  → excluded
  #   labels: frontend (#3B82F6), backend (#10B981), bugfix (#EF4444)
  #   comments on active_task: user_comment + agent_comment = 2 total
  #
  # user_two_project (owner: admin)
  #   board_columns: none (fixture has none)
  #   tasks:  high_priority_task (backlog), agent_task (backlog) — no comments
  #   labels: none

  # ---------------------------------------------------------------------------
  # Project name and link
  # ---------------------------------------------------------------------------

  test "renders project name" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_text project.name
  end

  test "renders project name as a link to the project" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    # URL helpers are unavailable in ViewComponent::TestCase — assert href contains the project id
    assert_selector "a[href*='/projects/#{project.id}']"
  end

  # ---------------------------------------------------------------------------
  # Description
  # ---------------------------------------------------------------------------

  test "renders description when present" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_text project.description
  end

  test "does not render description section when description is blank" do
    project = projects(:user_two_project)
    project.description = nil
    render_inline(ProjectCardComponent.new(project: project))
    assert_no_text "A test project for user two"
  end

  # ---------------------------------------------------------------------------
  # Progress bar
  # ---------------------------------------------------------------------------

  test "renders progress bar with role progressbar" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "[role='progressbar']"
  end

  test "renders progress bar with correct aria-valuenow" do
    # user_one_project: 1 active task (active_task in todo), 0 done → 0%
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "[role='progressbar'][aria-valuenow='0']"
  end

  test "renders completion percentage label on progress bar" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "[aria-label='Completion: 0%']"
  end

  # ---------------------------------------------------------------------------
  # Column task badges
  # ---------------------------------------------------------------------------

  test "renders task badge for columns that have active tasks" do
    # active_task is in todo column → badge shows "Todo:1"
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "[aria-label='Tasks by column']"
    assert_text "Todo:1"
  end

  test "does not render badge for columns with zero active tasks" do
    # backlog, in_progress, review, done all have 0 active tasks for user_one_project
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_no_text "Backlog:0"
    assert_no_text "Done:0"
  end

  test "excludes soft-deleted tasks from column badge counts" do
    # deleted_task is in todo but has deleted_at set — should not inflate the count
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    # Only active_task remains in todo, so count must be 1, not 2
    assert_text "Todo:1"
    assert_no_text "Todo:2"
  end

  # ---------------------------------------------------------------------------
  # Label color dots
  # ---------------------------------------------------------------------------

  test "renders label section wrapper when project has labels" do
    project = projects(:user_one_project) # 3 labels
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "[aria-label='Labels']"
  end

  test "renders color dot for each label" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "span[style*='background-color: #3B82F6']" # frontend
    assert_selector "span[style*='background-color: #10B981']" # backend
    assert_selector "span[style*='background-color: #EF4444']" # bugfix
  end

  test "does not render label dots when project has no labels" do
    project = projects(:user_two_project) # no labels
    render_inline(ProjectCardComponent.new(project: project))
    assert_no_selector "[aria-label='Labels']"
    assert_no_selector "span[style*='background-color']"
  end

  # ---------------------------------------------------------------------------
  # Comment count
  # ---------------------------------------------------------------------------

  test "renders comment count when project has comments" do
    # active_task has 2 comments (user_comment + agent_comment)
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "[aria-label='2 comments']"
    assert_text "2"
  end

  test "does not render comment icon when project has no comments" do
    # user_two_project tasks have no comments
    project = projects(:user_two_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_no_selector "[aria-label*='comments']"
  end

  test "excludes soft-deleted tasks from comment count" do
    # deleted_task has no comments but even if it did they must not be counted
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    # Only active_task's 2 comments should appear
    assert_selector "[aria-label='2 comments']"
  end

  # ---------------------------------------------------------------------------
  # Neo-Brutalism style (default)
  # ---------------------------------------------------------------------------

  test "applies neo card border style by default" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    assert_selector "div.border-2"
  end

  test "applies neo hard shadow to card by default" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project))
    # neo card class includes shadow-[4px_4px_0px_#000000]
    assert_selector "div[class*='shadow-']"
  end

  test "applies modern style when explicitly requested" do
    project = projects(:user_one_project)
    render_inline(ProjectCardComponent.new(project: project, style: :modern))
    assert_selector "div.rounded-lg"
  end
end
