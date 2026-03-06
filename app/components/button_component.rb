# frozen_string_literal: true

class ButtonComponent < ApplicationComponent
  VARIANTS = {
    primary: "inline-flex items-center justify-center rounded-md bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:opacity-50 disabled:cursor-not-allowed",
    secondary: "inline-flex items-center justify-center rounded-md bg-white px-4 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed",
    danger: "inline-flex items-center justify-center rounded-md bg-red-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600 disabled:opacity-50 disabled:cursor-not-allowed"
  }.freeze

  def initialize(variant: :primary, tag: :button, href: nil, disabled: false, type: "button", **options)
    @variant = variant
    @tag = tag
    @href = href
    @disabled = disabled
    @type = type
    @options = options
  end

  private

  def css_classes
    safe_classes(VARIANTS[@variant], @options[:class])
  end
end
