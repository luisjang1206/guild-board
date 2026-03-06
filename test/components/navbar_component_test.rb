require "test_helper"

class NavbarComponentTest < ViewComponent::TestCase
  test "renders navbar with login links when no user" do
    render_inline(NavbarComponent.new(user: nil))
    assert_selector("nav[data-controller='navbar']")
    assert_selector("a", text: I18n.t("defaults.navigation.login"))
    assert_selector("a", text: I18n.t("defaults.navigation.signup"))
  end

  test "renders navbar with logout when user present" do
    user = users(:regular)
    render_inline(NavbarComponent.new(user: user))
    assert_text(I18n.t("defaults.navigation.logout"))
    assert_text(I18n.t("defaults.navigation.dashboard"))
  end

  test "renders mobile hamburger button" do
    render_inline(NavbarComponent.new)
    assert_selector("button[data-action='click->navbar#toggle']")
    assert_selector("[data-navbar-target='menu']")
  end
end
