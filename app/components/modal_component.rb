# frozen_string_literal: true

class ModalComponent < ApplicationComponent
  renders_one :trigger
  renders_one :body

  def initialize(style: :modern)
    @style = style
  end

  private

  def backdrop_classes
    neo? ? "hidden fixed inset-0 z-50 flex min-h-full items-center justify-center overflow-y-auto bg-black/50 p-4" : "hidden fixed inset-0 z-50 flex min-h-full items-center justify-center overflow-y-auto bg-gray-500/75 p-4"
  end

  def panel_classes
    neo? ? "relative w-full max-w-lg border-2 border-black bg-white p-6 shadow-[8px_8px_0px_#000000]" : "relative w-full max-w-lg rounded-lg bg-white p-6 shadow-xl"
  end

  def close_button_classes
    neo? ? "border-2 border-black bg-white p-1 text-black shadow-[2px_2px_0px_#000000] transition-all hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_#000000]" : "rounded-md text-gray-400 hover:text-gray-500 focus:outline-none"
  end
end
