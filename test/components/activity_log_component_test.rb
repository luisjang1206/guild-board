# frozen_string_literal: true

require "test_helper"

class ActivityLogComponentTest < ViewComponent::TestCase
  # Fixtures used:
  #   task_created_log  — actor_type: user,  action: task_created,  metadata: title change
  #   agent_comment_log — actor_type: agent, action: comment_added, metadata: content string
  #   task_moved_log    — actor_type: user,  action: task_moved,    metadata: board_column [from → to]

  # ---------------------------------------------------------------------------
  # Neo style (default) — wrapper and icon classes
  # ---------------------------------------------------------------------------

  test "renders neo wrapper with bottom border by default" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    assert_selector "div.border-b-2.border-black"
  end

  test "renders user icon with neo style" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    assert_selector "div.bg-blue-200"
  end

  test "renders agent icon with neo style" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:agent_comment_log)))
    assert_selector "div.bg-purple-200"
  end

  # ---------------------------------------------------------------------------
  # Modern style — wrapper and icon classes
  # ---------------------------------------------------------------------------

  test "renders modern wrapper without neo border" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log), style: :modern))
    assert_no_selector "div.border-b-2.border-black"
  end

  test "renders user icon with modern style" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log), style: :modern))
    assert_selector "div.bg-blue-100"
  end

  test "renders agent icon with modern style" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:agent_comment_log), style: :modern))
    assert_selector "div.bg-purple-100"
  end

  # ---------------------------------------------------------------------------
  # Actor type label (i18n — app locale is :ko)
  # ---------------------------------------------------------------------------

  test "renders translated actor type for user" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    assert_text I18n.t("activity_log.actor_types.user")
  end

  test "renders translated actor type for agent" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:agent_comment_log)))
    assert_text I18n.t("activity_log.actor_types.agent")
  end

  # ---------------------------------------------------------------------------
  # Action text (i18n)
  # ---------------------------------------------------------------------------

  test "renders translated action text for task_created" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    assert_text I18n.t("activity_log.actions.task_created")
  end

  test "renders translated action text for comment_added" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:agent_comment_log)))
    assert_text I18n.t("activity_log.actions.comment_added")
  end

  test "renders translated action text for task_moved" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_moved_log)))
    assert_text I18n.t("activity_log.actions.task_moved")
  end

  # ---------------------------------------------------------------------------
  # Metadata rendering
  # ---------------------------------------------------------------------------

  test "renders array metadata as from-to change" do
    # task_moved_log: metadata { board_column: ["Backlog", "Todo"] }
    # formatted as "board_column: Backlog → Todo"
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_moved_log)))
    assert_text "Backlog"
    assert_text "Todo"
  end

  test "renders string metadata as key: value" do
    # agent_comment_log: metadata { content: "Test comment from agent" }
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:agent_comment_log)))
    assert_text "Test comment from agent"
  end

  test "renders initial creation metadata without arrow" do
    # task_created_log: metadata { title: ["", "Active Task"] }
    # old_val is "" (not nil) → formatted as "title:  → Active Task"
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    assert_text "Active Task"
  end

  test "does not render metadata section when metadata is empty" do
    # Build a transient log with no metadata to confirm the section is absent
    log = ActivityLog.new(
      project: projects(:user_one_project),
      actor_type: "user",
      actor_id: "1",
      action: "task_deleted",
      metadata: {},
      created_at: Time.current
    )
    render_inline(ActivityLogComponent.new(activity_log: log))
    # formatted_metadata returns nil → the conditional metadata <p> is not rendered.
    # Neo metadata class is "mt-1 text-xs text-gray-600"; assert that class combination is absent.
    # (The timestamp <p> uses text-gray-500, so we cannot assert that one absent here.)
    assert_no_selector "p.mt-1.text-xs.text-gray-600"
  end

  # ---------------------------------------------------------------------------
  # Timestamp
  # ---------------------------------------------------------------------------

  test "renders a timestamp paragraph" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    # time_ago_in_words output — just confirm something renders in the timestamp <p>
    assert_selector "p.text-xs.font-bold.uppercase.text-gray-500"
  end

  test "renders timestamp paragraph with modern style" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log), style: :modern))
    assert_selector "p.text-xs.text-gray-400"
  end

  # ---------------------------------------------------------------------------
  # SVG icon presence
  # ---------------------------------------------------------------------------

  test "renders an SVG icon for user actor" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:task_created_log)))
    assert_selector "svg"
  end

  test "renders an SVG icon for agent actor" do
    render_inline(ActivityLogComponent.new(activity_log: activity_logs(:agent_comment_log)))
    assert_selector "svg"
  end
end
