# frozen_string_literal: true

class CardComponent < ApplicationComponent
  VARIANTS = {
    default: "rounded-lg bg-white shadow p-6",
    bordered: "rounded-lg bg-white border border-gray-200 p-6"
  }.freeze

  renders_one :title
  renders_one :body
  renders_one :footer

  def initialize(variant: :default)
    @variant = variant
  end

  private

  def css_classes
    VARIANTS[@variant]
  end
end
