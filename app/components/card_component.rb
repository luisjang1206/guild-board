# frozen_string_literal: true

class CardComponent < ApplicationComponent
  VARIANTS = {
    default: "rounded-lg bg-white shadow p-6",
    bordered: "rounded-lg bg-white border border-gray-200 p-6"
  }.freeze

  NEO_VARIANTS = {
    default: "border-2 border-black bg-white p-6 shadow-[4px_4px_0px_#000000]",
    bordered: "border-2 border-black bg-white p-6 shadow-[4px_4px_0px_#000000]"
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
    resolve_variants(@variant, VARIANTS, NEO_VARIANTS)
  end

  def title_classes
    neo? ? "mb-4 text-lg font-bold uppercase text-black" : "mb-4 text-lg font-semibold text-gray-900"
  end

  def body_classes
    neo? ? "text-black" : "text-gray-700"
  end

  def footer_classes
    neo? ? "mt-4 border-t-2 border-black pt-4" : "mt-4 border-t border-gray-100 pt-4"
  end
end
