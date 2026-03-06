# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin
    layout "admin"

    private

    # admin? 또는 super_admin? 역할만 접근 허용
    # Current.user nil → safe navigation → false → 403
    def require_admin
      raise Pundit::NotAuthorizedError unless Current.user&.admin? || Current.user&.super_admin?
    end
  end
end
