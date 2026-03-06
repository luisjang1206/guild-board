require "test_helper"

class LocaleKeysTest < ActiveSupport::TestCase
  # 앱 전용 키만 비교 (Rails 표준 i18n 키: date, time, number, errors 등은 제외)
  APP_SCOPES = %w[defaults registrations sessions passwords rate_limit admin].freeze

  test "ko and en locales have matching app keys" do
    ko_keys = app_keys(:ko)
    en_keys = app_keys(:en)

    missing_in_en = ko_keys - en_keys
    missing_in_ko = en_keys - ko_keys

    assert missing_in_en.empty?, "Keys in ko but missing in en: #{missing_in_en.join(', ')}"
    assert missing_in_ko.empty?, "Keys in en but missing in ko: #{missing_in_ko.join(', ')}"
  end

  test "defaults.buttons keys exist in ko" do
    assert_not_nil I18n.t("defaults.buttons.submit", locale: :ko, raise: true)
    assert_not_nil I18n.t("defaults.buttons.save", locale: :ko, raise: true)
    assert_not_nil I18n.t("defaults.buttons.cancel", locale: :ko, raise: true)
  end

  test "defaults.navigation keys exist in ko" do
    assert_not_nil I18n.t("defaults.navigation.home", locale: :ko, raise: true)
    assert_not_nil I18n.t("defaults.navigation.login", locale: :ko, raise: true)
    assert_not_nil I18n.t("defaults.navigation.logout", locale: :ko, raise: true)
  end

  private

  def app_keys(locale)
    translations = I18n.backend.translations[locale] || {}
    APP_SCOPES.flat_map do |scope|
      flatten_keys(translations[scope.to_sym] || {}, scope)
    end
  end

  def flatten_keys(hash, prefix = "")
    hash.each_with_object([]) do |(key, value), keys|
      full_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      if value.is_a?(Hash)
        keys.concat(flatten_keys(value, full_key))
      else
        keys << full_key
      end
    end
  end
end
