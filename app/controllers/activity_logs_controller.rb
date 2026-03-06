# frozen_string_literal: true

class ActivityLogsController < ApplicationController
  before_action :set_project

  def index
    authorize @project, :show?
    scope = @project.activity_logs.includes(:task).order(created_at: :desc)
    scope = scope.where(task_id: params[:task_id]) if params[:task_id].present?
    @pagy, @activity_logs = pagy(scope)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
