# frozen_string_literal: true

# db/seeds/ 디렉토리 하위 파일을 알파벳 순서대로 로드
Dir[Rails.root.join("db/seeds/*.rb")].sort.each { |f| load f }
