# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  VARIANTS = {
    notice: "border-l-4 border-green-400 bg-green-50 p-4 text-green-800",
    alert: "border-l-4 border-yellow-400 bg-yellow-50 p-4 text-yellow-800",
    error: "border-l-4 border-red-400 bg-red-50 p-4 text-red-800"
  }.freeze

  # notice/alert는 Rails 표준, error는 추가
  VARIANT_MAPPING = {
    "notice" => :notice,
    "alert" => :alert,
    "error" => :error
  }.freeze

  def initialize(flash:)
    @flash = flash
  end

  def render?
    @flash.any?
  end

  private

  def variant_for(type)
    VARIANT_MAPPING[type.to_s] || :notice
  end

  def css_classes_for(type)
    VARIANTS[variant_for(type)]
  end
end
