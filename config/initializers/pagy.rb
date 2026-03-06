# frozen_string_literal: true

# Pagy 43+ configuration
# API 변경: Pagy::DEFAULT → Pagy.options, :items → :limit, :size → :slots (Integer)
Pagy.options[:limit] = 25
Pagy.options[:slots] = 7
Pagy.options[:page_key] = "page"

# 런타임 설정 변경 방지
Pagy.options.freeze
