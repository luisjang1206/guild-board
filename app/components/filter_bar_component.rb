# frozen_string_literal: true

class FilterBarComponent < ApplicationComponent
  def initialize(project:, labels:, filters: {})
    @project = project
    @labels = labels
    @filters = filters
  end
end
