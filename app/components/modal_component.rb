# frozen_string_literal: true

class ModalComponent < ApplicationComponent
  STYLES = {
    modern: {
      backdrop: "hidden fixed inset-0 z-50 flex min-h-full items-center justify-center overflow-y-auto bg-gray-500/75 p-4",
      panel: "relative w-full max-w-lg rounded-lg bg-white p-6 shadow-xl",
      close_button: "rounded-md text-gray-400 hover:text-gray-500 focus:outline-none"
    },
    neo: {
      backdrop: "hidden fixed inset-0 z-50 flex min-h-full items-center justify-center overflow-y-auto bg-black/50 p-4",
      panel: "relative w-full max-w-lg border-2 border-black bg-white p-6 shadow-[8px_8px_0px_#000000]",
      close_button: "border-2 border-black bg-white p-1 text-black shadow-[2px_2px_0px_#000000] transition-all hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_#000000]"
    }
  }.freeze

  renders_one :trigger
  renders_one :body

  def initialize(style: :modern)
    @style = style
  end

  private

  def backdrop_classes
    style_for(:backdrop)
  end

  def panel_classes
    style_for(:panel)
  end

  def close_button_classes
    style_for(:close_button)
  end
end
