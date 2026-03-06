# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
      @user_count = User.count
      @recent_users = User.order(created_at: :desc).limit(5)
    end
  end
end
