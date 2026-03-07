# frozen_string_literal: true

class EmptyStateComponent < ApplicationComponent
  STYLES = {
    modern: {
      wrapper: "py-12 text-center",
      icon: "mx-auto mb-4 text-gray-400",
      message: "text-sm text-gray-500"
    },
    neo: {
      wrapper: "border-2 border-black border-dashed bg-white py-12 text-center shadow-[4px_4px_0px_var(--color-black)]",
      icon: "mx-auto mb-4 text-black",
      message: "text-sm font-bold uppercase text-black"
    }
  }.freeze

  renders_one :icon
  renders_one :action

  def initialize(message:, style: :modern)
    @message = message
    @style = style
  end

  private

  def wrapper_classes
    style_for(:wrapper)
  end

  def icon_classes
    style_for(:icon)
  end

  def message_classes
    style_for(:message)
  end
end
