# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # 사용자 목록: 관리자만 접근
  def index?
    user.admin? || user.super_admin?
  end

  # 사용자 상세: 자기 자신 + 관리자
  def show?
    user == record || user.admin? || user.super_admin?
  end

  # 사용자 수정: 자기 자신 + 슈퍼관리자
  def update?
    user == record || user.super_admin?
  end

  # 역할 변경: 슈퍼관리자만
  def change_role?
    user.super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.super_admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
