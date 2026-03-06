require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  test "renders primary button by default" do
    render_inline(ButtonComponent.new) { "Click me" }
    assert_selector("button[type='button']", text: "Click me")
    assert_selector("button.bg-indigo-600")
  end

  test "renders secondary variant" do
    render_inline(ButtonComponent.new(variant: :secondary)) { "Cancel" }
    assert_selector("button.ring-1")
    assert_no_selector("button.bg-indigo-600")
  end

  test "renders danger variant" do
    render_inline(ButtonComponent.new(variant: :danger)) { "Delete" }
    assert_selector("button.bg-red-600")
  end

  test "renders as link when tag is :a" do
    render_inline(ButtonComponent.new(tag: :a, href: "/path")) { "Link" }
    assert_selector("a[href='/path']", text: "Link")
    assert_no_selector("button")
  end

  test "renders disabled button" do
    render_inline(ButtonComponent.new(disabled: true)) { "Disabled" }
    assert_selector("button[disabled]")
  end
end
