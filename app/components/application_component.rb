class ApplicationComponent < ViewComponent::Base
  STYLES = %i[modern neo].freeze

  private

  def safe_classes(*args)
    args.compact.join(" ")
  end

  def neo?
    @style == :neo
  end

  def resolve_variants(variant, modern_variants, neo_variants)
    neo? ? neo_variants[variant] : modern_variants[variant]
  end
end
