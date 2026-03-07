# frozen_string_literal: true

class BadgeComponent < ApplicationComponent
  STYLES = {
    modern: {
      success: "inline-flex items-center rounded-full bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20",
      warning: "inline-flex items-center rounded-full bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20",
      error: "inline-flex items-center rounded-full bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/20",
      info: "inline-flex items-center rounded-full bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-600/20"
    },
    neo: {
      success: "inline-flex items-center border-2 border-black bg-green-200 px-2 py-0.5 text-xs font-bold uppercase shadow-[2px_2px_0px_var(--color-black)]",
      warning: "inline-flex items-center border-2 border-black bg-yellow-200 px-2 py-0.5 text-xs font-bold uppercase shadow-[2px_2px_0px_var(--color-black)]",
      error: "inline-flex items-center border-2 border-black bg-red-200 px-2 py-0.5 text-xs font-bold uppercase shadow-[2px_2px_0px_var(--color-black)]",
      info: "inline-flex items-center border-2 border-black bg-blue-200 px-2 py-0.5 text-xs font-bold uppercase shadow-[2px_2px_0px_var(--color-black)]"
    }
  }.freeze

  def initialize(variant: :info, label:, style: :modern)
    @variant = variant
    @label = label
    @style = style
  end

  private

  def css_classes
    style_for(@variant)
  end
end
