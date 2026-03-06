require "test_helper"

class FilterBarComponentTest < ViewComponent::TestCase
  # user_one_project labels: frontend (#3B82F6), backend (#10B981), bugfix (#EF4444)

  setup do
    @project = projects(:user_one_project)
    @labels = @project.labels.order(:name)
  end

  # ---------------------------------------------------------------------------
  # Structure
  # ---------------------------------------------------------------------------

  test "renders filter controller wrapper" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels))
    assert_selector "[data-controller='filter']"
  end

  test "renders priority select" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels))
    assert_selector "select#filter-priority"
  end

  test "renders label select" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels))
    assert_selector "select#filter-label"
  end

  test "renders creator type select" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels))
    assert_selector "select#filter-creator-type"
  end

  # ---------------------------------------------------------------------------
  # Labels
  # ---------------------------------------------------------------------------

  test "renders an option for each label" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels))
    @labels.each do |label|
      assert_selector "select#filter-label option[value='#{label.id}']"
    end
  end

  test "renders no label options when labels collection is empty" do
    render_inline(FilterBarComponent.new(project: @project, labels: Label.none))
    # Only the "all labels" blank option should be present
    assert_selector "select#filter-label option", count: 1
  end

  # ---------------------------------------------------------------------------
  # No active filters — indicator must be absent
  # ---------------------------------------------------------------------------

  test "does not render active filter indicator when filters are empty" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels))
    assert_no_selector "[data-action='click->filter#clearAll']"
  end

  # ---------------------------------------------------------------------------
  # Active filters — pre-selection and indicator
  # ---------------------------------------------------------------------------

  test "pre-selects the matching priority option" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels, filters: { priority: "high" }))
    assert_selector "select#filter-priority option[value='high'][selected]"
  end

  test "pre-selects the matching label option" do
    label = labels(:frontend)
    render_inline(FilterBarComponent.new(project: @project, labels: @labels, filters: { label_id: label.id }))
    assert_selector "select#filter-label option[value='#{label.id}'][selected]"
  end

  test "pre-selects the matching creator type option" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels, filters: { creator_type: "agent" }))
    assert_selector "select#filter-creator-type option[value='agent'][selected]"
  end

  test "renders active filter indicator when filters are present" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels, filters: { priority: "low" }))
    assert_selector "[data-action='click->filter#clearAll']"
  end

  test "renders clear button when filters are present" do
    render_inline(FilterBarComponent.new(project: @project, labels: @labels, filters: { creator_type: "user" }))
    # The clear button carries both the action and a visually distinct bg-yellow-300 sibling badge
    assert_selector "button[data-action='click->filter#clearAll']"
  end
end
