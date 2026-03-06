# frozen_string_literal: true

class TaskCardComponent < ApplicationComponent
  PRIORITY_VARIANTS = {
    "high" => :error,
    "medium" => :warning,
    "low" => :info
  }.freeze

  def initialize(task:)
    @task = task
  end

  private

  def priority_variant
    PRIORITY_VARIANTS[@task.priority] || :info
  end

  def checklist_progress
    total = @task.checklists.size
    return nil if total.zero?
    completed = @task.checklists.count { |c| c.completed? }
    { completed: completed, total: total }
  end

  def comment_count
    @task.comments.size
  end

  def label_colors
    @task.labels.map do |l|
      color = l.color.match?(/\A#[0-9a-fA-F]{6}\z/) ? l.color : "#cccccc"
      { name: l.name, color: color }
    end
  end

  def creator_icon
    @task.creator_type
  end

  def project
    @task.project
  end
end
