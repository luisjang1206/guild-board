# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  VARIANTS = {
    notice: "border-l-4 border-green-400 bg-green-50 p-4 text-green-800",
    alert: "border-l-4 border-yellow-400 bg-yellow-50 p-4 text-yellow-800",
    error: "border-l-4 border-red-400 bg-red-50 p-4 text-red-800"
  }.freeze

  NEO_VARIANTS = {
    notice: "border-2 border-black bg-green-200 p-4 text-black shadow-[4px_4px_0px_#000000]",
    alert: "border-2 border-black bg-yellow-200 p-4 text-black shadow-[4px_4px_0px_#000000]",
    error: "border-2 border-black bg-red-200 p-4 text-black shadow-[4px_4px_0px_#000000]"
  }.freeze

  # notice/alert는 Rails 표준, error는 추가
  VARIANT_MAPPING = {
    "notice" => :notice,
    "alert" => :alert,
    "error" => :error
  }.freeze

  def initialize(flash:, style: :modern)
    @flash = flash
    @style = style
  end

  def render?
    @flash.any?
  end

  private

  def variant_for(type)
    VARIANT_MAPPING[type.to_s] || :notice
  end

  def css_classes_for(type)
    resolve_variants(variant_for(type), VARIANTS, NEO_VARIANTS)
  end

  def wrapper_classes
    neo? ? "" : "rounded-md"
  end

  def message_classes
    neo? ? "text-sm font-bold uppercase" : "text-sm font-medium"
  end

  def dismiss_button_classes
    neo? ? "ml-4 inline-flex shrink-0 border-2 border-black p-1 hover:bg-black/10 focus:outline-none" : "ml-4 inline-flex shrink-0 rounded-md p-1.5 hover:bg-black/5 focus:outline-none"
  end
end
