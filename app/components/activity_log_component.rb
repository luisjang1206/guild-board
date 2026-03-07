# frozen_string_literal: true

class ActivityLogComponent < ApplicationComponent
  STYLES = {
    modern: {
      wrapper: "flex items-start gap-3 py-3",
      icon_user: "flex-shrink-0 h-8 w-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center",
      icon_agent: "flex-shrink-0 h-8 w-8 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center",
      content: "flex-1 min-w-0",
      action_text: "text-sm text-gray-900",
      metadata: "mt-1 text-xs text-gray-500",
      timestamp: "text-xs text-gray-400"
    },
    neo: {
      wrapper: "flex items-start gap-3 border-b-2 border-black py-3 last:border-b-0",
      icon_user: "flex-shrink-0 h-8 w-8 border-2 border-black bg-blue-200 flex items-center justify-center shadow-[2px_2px_0px_var(--color-black)]",
      icon_agent: "flex-shrink-0 h-8 w-8 border-2 border-black bg-purple-200 flex items-center justify-center shadow-[2px_2px_0px_var(--color-black)]",
      content: "flex-1 min-w-0",
      action_text: "text-sm font-bold text-black",
      metadata: "mt-1 text-xs text-gray-600",
      timestamp: "text-xs font-bold uppercase text-gray-500"
    }
  }.freeze

  def initialize(activity_log:, style: :neo)
    @activity_log = activity_log
    @style = style
  end

  private

  def actor_icon_class
    @activity_log.actor_type == "agent" ? style_for(:icon_agent) : style_for(:icon_user)
  end

  def actor_icon_svg
    if @activity_log.actor_type == "agent"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "h-4 w-4") do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M8.25 3v1.5M4.5 8.25H3m18 0h-1.5M4.5 12H3m18 0h-1.5m-15 3.75H3m18 0h-1.5M8.25 19.5V21M12 3v1.5m0 15V21m3.75-18v1.5m0 15V21m-9-1.5h9a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0015.75 4.5h-7.5A2.25 2.25 0 006 6.75v10.5A2.25 2.25 0 008.25 19.5z")
      end
    else
      tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "h-4 w-4") do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z")
      end
    end
  end

  def action_text
    I18n.t("activity_log.actions.#{@activity_log.action}", default: @activity_log.action)
  end

  def formatted_metadata
    return nil if @activity_log.metadata.blank?

    changes = @activity_log.metadata.map do |key, value|
      if value.is_a?(Array) && value.length == 2
        old_val, new_val = value
        if old_val.nil?
          "#{key}: #{new_val}"
        elsif new_val.nil?
          "#{key}: #{old_val}"
        else
          "#{key}: #{old_val} → #{new_val}"
        end
      else
        "#{key}: #{value}"
      end
    end
    changes.join(", ")
  end

  def time_ago
    helpers.time_ago_in_words(@activity_log.created_at)
  end
end
