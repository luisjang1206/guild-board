require "test_helper"

class BadgeComponentTest < ViewComponent::TestCase
  test "renders info badge by default" do
    render_inline(BadgeComponent.new(label: "New"))
    assert_selector("span.bg-blue-50", text: "New")
  end

  test "renders success badge" do
    render_inline(BadgeComponent.new(variant: :success, label: "Active"))
    assert_selector("span.bg-green-50", text: "Active")
  end

  test "renders warning badge" do
    render_inline(BadgeComponent.new(variant: :warning, label: "Pending"))
    assert_selector("span.bg-yellow-50", text: "Pending")
  end

  test "renders error badge" do
    render_inline(BadgeComponent.new(variant: :error, label: "Failed"))
    assert_selector("span.bg-red-50", text: "Failed")
  end

  test "renders neo info badge" do
    render_inline(BadgeComponent.new(label: "New", style: :neo))
    assert_selector("span.border-2.border-black.bg-blue-200", text: "New")
    assert_no_selector("span.rounded-full")
  end

  test "renders neo success badge" do
    render_inline(BadgeComponent.new(variant: :success, label: "Active", style: :neo))
    assert_selector("span.border-2.border-black.bg-green-200", text: "Active")
  end

  test "renders neo warning badge" do
    render_inline(BadgeComponent.new(variant: :warning, label: "Pending", style: :neo))
    assert_selector("span.border-2.border-black.bg-yellow-200", text: "Pending")
  end

  test "renders neo error badge" do
    render_inline(BadgeComponent.new(variant: :error, label: "Failed", style: :neo))
    assert_selector("span.border-2.border-black.bg-red-200", text: "Failed")
  end
end
