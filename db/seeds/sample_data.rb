# frozen_string_literal: true

return unless Rails.env.development?

10.times do |i|
  User.find_or_create_by!(email_address: "user#{i + 1}@example.com") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = :user
  end
end

puts "Sample data seeded: #{User.count} users total"
