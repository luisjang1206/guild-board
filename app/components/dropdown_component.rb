# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  renders_one :trigger
  renders_many :items

  def initialize(style: :modern)
    @style = style
  end

  private

  def menu_classes
    base = "hidden absolute right-0 z-10 mt-2 w-48 origin-top-right"
    neo? ? "#{base} border-2 border-black bg-white shadow-[4px_4px_0px_#000000]" : "#{base} rounded-md bg-white shadow-lg ring-1 ring-black/5"
  end
end
