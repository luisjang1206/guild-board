require "test_helper"

class DropdownComponentTest < ViewComponent::TestCase
  test "renders dropdown with trigger and items" do
    render_inline(DropdownComponent.new) do |dropdown|
      dropdown.with_trigger { "Menu" }
      dropdown.with_item { "Item 1" }
      dropdown.with_item { "Item 2" }
    end
    assert_selector("[data-controller='dropdown']")
    assert_selector("[data-action='click->dropdown#toggle']", text: "Menu")
    assert_selector("[data-dropdown-target='menu']")
    assert_text("Item 1")
    assert_text("Item 2")
  end

  test "menu has role=menu attribute" do
    render_inline(DropdownComponent.new) do |dropdown|
      dropdown.with_trigger { "Menu" }
    end
    assert_selector("[role='menu']")
  end

  test "renders neo dropdown menu with hard shadow" do
    render_inline(DropdownComponent.new(style: :neo)) do |dropdown|
      dropdown.with_trigger { "Menu" }
      dropdown.with_item { "Item 1" }
    end
    assert_selector("[data-dropdown-target='menu'].border-2.border-black")
    assert_no_selector("[data-dropdown-target='menu'].rounded-md")
  end
end
