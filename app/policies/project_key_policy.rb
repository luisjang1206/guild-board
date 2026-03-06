class ProjectKeyPolicy < ApplicationPolicy
  def index?
    project_owner?
  end

  def create?
    project_owner?
  end

  def destroy?
    project_owner?
  end

  def toggle_active?
    project_owner?
  end

  def regenerate?
    project_owner?
  end

  private

  def project_owner?
    record.project.user == user
  end
end
