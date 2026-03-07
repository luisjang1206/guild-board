# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  STYLES = {
    modern: {
      menu: "hidden absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black/5"
    },
    neo: {
      menu: "hidden absolute right-0 z-10 mt-2 w-48 origin-top-right border-2 border-black bg-white shadow-[4px_4px_0px_var(--color-black)]"
    }
  }.freeze

  renders_one :trigger
  renders_many :items

  def initialize(style: :modern)
    @style = style
  end

  private

  def menu_classes
    style_for(:menu)
  end
end
