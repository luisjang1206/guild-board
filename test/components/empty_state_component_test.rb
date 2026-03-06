require "test_helper"

class EmptyStateComponentTest < ViewComponent::TestCase
  test "renders message" do
    render_inline(EmptyStateComponent.new(message: "No items found"))
    assert_text("No items found")
    assert_selector("div.text-center")
  end

  test "renders icon slot" do
    render_inline(EmptyStateComponent.new(message: "Empty")) do |empty|
      empty.with_icon { "<svg>icon</svg>".html_safe }
    end
    assert_selector("svg")
  end

  test "renders action slot" do
    render_inline(EmptyStateComponent.new(message: "Empty")) do |empty|
      empty.with_action { "Add new" }
    end
    assert_text("Add new")
  end
end
