require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]

  # Sign in via the UI login form.
  # This uses the real session endpoint so the browser receives a real cookie.
  def sign_in_via_ui(email:, password:)
    visit new_session_path
    # The login form has no <label> tags — locate fields by their rendered id
    # attributes: form.email_field(:email_address) → id="email_address",
    # form.password_field(:password) → id="password".
    find("#email_address").fill_in with: email
    find("#password").fill_in with: password
    click_on "Sign in"
    # Wait for redirect away from the login page before returning
    assert_no_current_path new_session_path, wait: 5
  end
end
