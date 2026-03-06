# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  renders_one :trigger
  renders_many :items
end
