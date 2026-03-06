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

  test "renders neo style input" do
    with_rendered_component(style: :neo) do
      assert_selector("label.font-bold.uppercase")
      assert_selector("input.border-2.border-black")
      assert_no_selector("input.rounded-md")
    end
  end

  test "renders neo style input with errors" do
    with_rendered_component(error_messages: [ "can't be blank" ], style: :neo) do
      assert_selector("input.border-2.border-red-600")
      assert_selector("p.font-bold", text: "can't be blank")
    end
  end

  private

  def with_rendered_component(error_messages: nil, style: :modern, &block)
    vc_test_controller.view_context.form_with(model: @user, url: "/test") do |form|
      render_inline(FormFieldComponent.new(
        form: form,
        field_name: :email_address,
        label: "Name",
        error_messages: error_messages,
        style: style
      ))
    end
    yield
  end
end
