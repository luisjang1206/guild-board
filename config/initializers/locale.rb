Rails.application.configure do
  config.i18n.default_locale = :ko
  config.i18n.available_locales = [ :ko, :en ]
  config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]
end
