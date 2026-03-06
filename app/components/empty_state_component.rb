# frozen_string_literal: true

class EmptyStateComponent < ApplicationComponent
  renders_one :icon
  renders_one :action

  def initialize(message:, style: :modern)
    @message = message
    @style = style
  end

  private

  def wrapper_classes
    neo? ? "border-2 border-black border-dashed bg-white py-12 text-center shadow-[4px_4px_0px_#000000]" : "py-12 text-center"
  end

  def icon_classes
    neo? ? "mx-auto mb-4 text-black" : "mx-auto mb-4 text-gray-400"
  end

  def message_classes
    neo? ? "text-sm font-bold uppercase text-black" : "text-sm text-gray-500"
  end
end
