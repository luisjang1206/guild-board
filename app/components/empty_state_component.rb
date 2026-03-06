# frozen_string_literal: true

class EmptyStateComponent < ApplicationComponent
  renders_one :icon
  renders_one :action

  def initialize(message:)
    @message = message
  end
end
