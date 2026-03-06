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
end
