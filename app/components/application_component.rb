class ApplicationComponent < ViewComponent::Base
  private

  def safe_classes(*args)
    args.compact.join(" ")
  end

  def neo?
    @style == :neo
  end

  def style_for(element)
    self.class::STYLES.dig(@style, element)
  end
end
