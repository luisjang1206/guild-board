require "test_helper"

class FlashComponentTest < ViewComponent::TestCase
  test "renders notice flash message" do
    render_inline(FlashComponent.new(flash: { notice: "Success!" }))
    assert_selector("[data-controller='flash']")
    assert_text("Success!")
    assert_selector(".border-green-400")
  end

  test "renders alert flash message" do
    render_inline(FlashComponent.new(flash: { alert: "Warning!" }))
    assert_selector(".border-yellow-400")
    assert_text("Warning!")
  end

  test "renders error flash message" do
    render_inline(FlashComponent.new(flash: { error: "Error!" }))
    assert_selector(".border-red-400")
    assert_text("Error!")
  end

  test "does not render when flash is empty" do
    render_inline(FlashComponent.new(flash: {}))
    assert_no_selector("[data-controller='flash']")
  end

  test "renders dismiss button" do
    render_inline(FlashComponent.new(flash: { notice: "Test" }))
    assert_selector("button[data-action='click->flash#dismiss']")
  end
end
