# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  def initialize(pagy:)
    @pagy = pagy
  end

  def render?
    @pagy.pages > 1
  end
end
