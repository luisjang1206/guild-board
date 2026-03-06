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

  test "renders neo primary button" do
    render_inline(ButtonComponent.new(style: :neo)) { "Click" }
    assert_selector("button.border-2.border-black.bg-yellow-300")
    assert_no_selector("button.bg-indigo-600")
  end

  test "renders neo secondary button" do
    render_inline(ButtonComponent.new(variant: :secondary, style: :neo)) { "Cancel" }
    assert_selector("button.border-2.border-black.bg-white")
    assert_no_selector("button.ring-1")
  end

  test "renders neo danger button" do
    render_inline(ButtonComponent.new(variant: :danger, style: :neo)) { "Delete" }
    assert_selector("button.border-2.border-black.bg-red-100")
    assert_no_selector("button.bg-red-600")
  end
end
