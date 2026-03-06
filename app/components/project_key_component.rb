# frozen_string_literal: true

class ProjectKeyComponent < ApplicationComponent
  def initialize(project_key:, project:, raw_key: nil)
    @project_key = project_key
    @project = project
    @raw_key = raw_key
  end

  private

  def badge_variant
    @project_key.active? ? :success : :warning
  end

  def badge_label
    @project_key.active? ? t("project_keys.component.active") : t("project_keys.component.inactive")
  end

  def last_used_text
    @project_key.last_used_at ? l(@project_key.last_used_at, format: :short) : t("project_keys.component.never_used")
  end
end
