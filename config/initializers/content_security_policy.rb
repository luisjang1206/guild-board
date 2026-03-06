# Content Security Policy (CSP) — PRD 3.7
# https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
#
# Tailwind CSS v4 + Import Maps + Turbo/Stimulus 호환 설정
# 프로덕션 배포 전 report_only → enforce 전환 권장

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self, :unsafe_inline, "https://cdn.jsdelivr.net"
    policy.style_src   :self, :unsafe_inline
    if Rails.env.production?
      policy.connect_src :self, "wss://#{ENV.fetch('APP_DOMAIN', 'localhost')}"
    else
      policy.connect_src :self, "ws://localhost:*", "wss://localhost:*"
    end
  end

  # Enforce CSP (report_only = false means violations are blocked, not just reported)
  config.content_security_policy_report_only = false
end
