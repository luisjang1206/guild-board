# frozen_string_literal: true

class NavbarComponent < ApplicationComponent
  def initialize(user: nil)
    @user = user
  end

  private

  def signed_in?
    @user.present?
  end
end
