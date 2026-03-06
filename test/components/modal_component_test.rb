require "test_helper"

class ModalComponentTest < ViewComponent::TestCase
  test "renders modal with trigger and body" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_trigger { "Open" }
      modal.with_body { "Modal content" }
    end
    assert_selector("[data-controller='modal']")
    assert_selector("[data-action='click->modal#open']", text: "Open")
    assert_selector("[data-modal-target='dialog']")
    assert_text("Modal content")
  end

  test "renders close button" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_body { "Content" }
    end
    assert_selector("button[data-action='click->modal#close']")
  end

  test "dialog has backdrop click handler" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_body { "Content" }
    end
    assert_selector("[data-action='click->modal#closeOnBackdrop']")
  end
end
