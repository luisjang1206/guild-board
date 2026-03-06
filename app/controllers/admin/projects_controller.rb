# frozen_string_literal: true

module Admin
  class ProjectsController < BaseController
    def index
      @pagy, @projects = pagy(Project.includes(:user, :project_keys, :tasks).order(created_at: :desc))
    end

    def show
      @project = Project.includes(:user).find(params[:id])
      @tasks_count = @project.tasks.count
      @active_keys_count = @project.project_keys.active.count
      @recent_activities = @project.activity_logs.order(created_at: :desc).limit(10)
      @project_keys = @project.project_keys.order(created_at: :desc)
    end
  end
end
