class ApplicationComponent < ViewComponent::Base
  private

  def safe_classes(*args)
    args.compact.join(" ")
  end
end
