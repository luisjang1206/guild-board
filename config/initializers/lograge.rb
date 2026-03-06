# frozen_string_literal: true

Rails.application.configure do
  # production 환경 기본 활성화, 다른 환경은 ENV 플래그로 활성화 가능
  config.lograge.enabled = Rails.env.production? || ENV["LOGRAGE_ENABLED"].present?

  # JSON 포맷 — 구조화된 로그 분석에 적합
  config.lograge.formatter = Lograge::Formatters::Json.new

  # 요청별 커스텀 페이로드: 사용자 ID, 요청 ID, 클라이언트 IP
  config.lograge.custom_payload do |controller|
    {
      user_id: Current.user&.id,
      request_id: controller.request.request_id,
      remote_ip: controller.request.remote_ip
    }
  end

  # Health check 엔드포인트 로그 제외 (노이즈 감소)
  # /up (liveness)은 Rails::HealthController이므로 별도 제외 불필요
  config.lograge.ignore_actions = [ "HealthController#show" ]
end
