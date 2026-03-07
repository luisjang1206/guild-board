# frozen_string_literal: true

class ButtonComponent < ApplicationComponent
  STYLES = {
    modern: {
      primary: "inline-flex items-center justify-center rounded-md bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:opacity-50 disabled:cursor-not-allowed",
      secondary: "inline-flex items-center justify-center rounded-md bg-white px-4 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed",
      danger: "inline-flex items-center justify-center rounded-md bg-red-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600 disabled:opacity-50 disabled:cursor-not-allowed"
    },
    neo: {
      primary: "inline-flex items-center justify-center border-2 border-black bg-yellow-300 px-4 py-2 text-sm font-bold uppercase shadow-[4px_4px_0px_var(--color-black)] transition-all hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_var(--color-black)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-[2px_2px_0px_var(--color-black)] disabled:opacity-50 disabled:cursor-not-allowed",
      secondary: "inline-flex items-center justify-center border-2 border-black bg-white px-4 py-2 text-sm font-bold uppercase shadow-[4px_4px_0px_var(--color-black)] transition-all hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_var(--color-black)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-[2px_2px_0px_var(--color-black)] disabled:opacity-50 disabled:cursor-not-allowed",
      danger: "inline-flex items-center justify-center border-2 border-black bg-red-100 px-4 py-2 text-sm font-bold uppercase shadow-[4px_4px_0px_var(--color-black)] transition-all hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_var(--color-black)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-[2px_2px_0px_var(--color-black)] disabled:opacity-50 disabled:cursor-not-allowed"
    }
  }.freeze

  def initialize(variant: :primary, tag: :button, href: nil, disabled: false, type: "button", style: :modern, **options)
    @variant = variant
    @tag = tag
    @href = href
    @disabled = disabled
    @type = type
    @style = style
    @options = options
  end

  private

  def css_classes
    safe_classes(style_for(@variant), @options[:class])
  end
end
