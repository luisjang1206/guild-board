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

  test "renders neo empty state with dashed border" do
    render_inline(EmptyStateComponent.new(message: "No items", style: :neo))
    assert_selector("div.border-2.border-black.border-dashed")
    assert_selector("p.font-bold.uppercase", text: "No items")
  end
end
