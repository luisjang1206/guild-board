# frozen_string_literal: true

module Admin
  class ProjectKeysController < BaseController
    def index
      @pagy, @project_keys = pagy(ProjectKey.includes(:project).order(created_at: :desc))
    end
  end
end
