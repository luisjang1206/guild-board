require "test_helper"

class FormFieldComponentTest < ViewComponent::TestCase
  setup do
    @user = User.new
  end

  test "renders text field with label" do
    with_rendered_component do
      assert_selector("label", text: "Name")
      assert_selector("input[type='text']")
    end
  end

  test "renders error messages" do
    with_rendered_component(error_messages: [ "can't be blank" ]) do
      assert_selector("p.text-red-600", text: "can't be blank")
    end
  end

  private

  def with_rendered_component(error_messages: nil, &block)
    vc_test_controller.view_context.form_with(model: @user, url: "/test") do |form|
      render_inline(FormFieldComponent.new(
        form: form,
        field_name: :email_address,
        label: "Name",
        error_messages: error_messages
      ))
    end
    yield
  end
end
