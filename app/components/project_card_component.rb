# frozen_string_literal: true

class ProjectCardComponent < ApplicationComponent
  STYLES = {
    modern: {
      card: "rounded-lg bg-white shadow-sm border border-gray-200 p-6 transition-all hover:shadow-md",
      title: "text-lg font-semibold text-gray-900 truncate",
      meta: "text-sm text-gray-500",
      divider: "border-t border-gray-100",
      label_dot: "h-3 w-3 rounded-full border border-gray-300 flex-shrink-0",
      badge: "rounded bg-gray-100 px-1.5 py-0.5 text-xs text-gray-600",
      remaining_badge: "rounded bg-gray-100 px-1 text-[10px] text-gray-500",
      progress_bar_bg: "h-2 w-full rounded-full bg-gray-100",
      progress_bar_fill: "h-2 rounded-full bg-indigo-500 transition-all",
      stat_label: "text-xs text-gray-500",
      stat_value: "text-sm font-medium text-gray-900"
    },
    neo: {
      card: "border-2 border-black bg-white p-6 shadow-[4px_4px_0px_#000000] transition-all hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000000]",
      title: "text-lg font-bold uppercase text-black truncate",
      meta: "text-xs font-bold text-black",
      divider: "border-t-2 border-black",
      label_dot: "h-3 w-3 rounded-full border-2 border-black flex-shrink-0",
      badge: "border-2 border-black bg-white px-1.5 py-0.5 text-xs font-bold uppercase shadow-[2px_2px_0px_#000000]",
      remaining_badge: "border-2 border-black bg-white px-1 text-[10px] font-bold uppercase shadow-[2px_2px_0px_#000000]",
      progress_bar_bg: "h-2 w-full border border-black bg-white",
      progress_bar_fill: "h-2 bg-black transition-all",
      stat_label: "text-xs font-bold uppercase text-black",
      stat_value: "text-sm font-bold text-black"
    }
  }.freeze

  def initialize(project:, style: :neo)
    @project = project
    @style = style
  end

  private

  def task_stats
    @task_stats ||= begin
      columns = @project.board_columns.map do |column|
        active = column.tasks.select { |t| t.deleted_at.nil? }
        { name: column.name, count: active.size }
      end

      total = columns.sum { |c| c[:count] }
      done_column = columns.find { |c| c[:name] == "Done" }
      done = done_column ? done_column[:count] : 0

      { columns: columns, total: total, done: done }
    end
  end

  def completion_percentage
    @completion_percentage ||= begin
      return 0 if task_stats[:total].zero?
      (task_stats[:done].to_f / task_stats[:total] * 100).round
    end
  end

  def label_colors
    @label_colors ||= @project.labels.first(5).map do |l|
      color = l.color.match?(/\A#[0-9a-fA-F]{6}\z/) ? l.color : "#cccccc"
      { name: l.name, color: color }
    end
  end

  def total_comment_count
    @total_comment_count ||= @project.tasks.select { |t| t.deleted_at.nil? }.sum { |t| t.comments.size }
  end

  def latest_activity_time
    @project.updated_at
  end

  def remaining_labels_count
    @remaining_labels_count ||= begin
      total = @project.labels.size
      displayed = [ total, 5 ].min
      total - displayed
    end
  end
end
