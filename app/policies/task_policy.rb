class TaskPolicy < ApplicationPolicy
  def show?
    project_owner?
  end

  def create?
    project_owner?
  end

  def update?
    project_owner?
  end

  def destroy?
    project_owner?
  end

  private

  def project_owner?
    record.project.user == user
  end
end
