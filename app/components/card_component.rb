# frozen_string_literal: true

class CardComponent < ApplicationComponent
  STYLES = {
    modern: {
      card: { default: "rounded-lg bg-white shadow p-6", bordered: "rounded-lg bg-white border border-gray-200 p-6" },
      title: "mb-4 text-lg font-semibold text-gray-900",
      body: "text-gray-700",
      footer: "mt-4 border-t border-gray-100 pt-4"
    },
    neo: {
      card: { default: "border-2 border-black bg-white p-6 shadow-[4px_4px_0px_var(--color-black)]", bordered: "border-2 border-black bg-white p-6 shadow-[4px_4px_0px_var(--color-black)]" },
      title: "mb-4 text-lg font-bold uppercase text-black",
      body: "text-black",
      footer: "mt-4 border-t-2 border-black pt-4"
    }
  }.freeze

  renders_one :title
  renders_one :body
  renders_one :footer

  def initialize(variant: :default, style: :modern)
    @variant = variant
    @style = style
  end

  private

  def css_classes
    style_for(:card)[@variant]
  end

  def title_classes
    style_for(:title)
  end

  def body_classes
    style_for(:body)
  end

  def footer_classes
    style_for(:footer)
  end
end
