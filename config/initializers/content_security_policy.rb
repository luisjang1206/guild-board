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
    policy.connect_src :self
  end

  # Report violations without blocking (switch to false for enforcement)
  config.content_security_policy_report_only = true
end
