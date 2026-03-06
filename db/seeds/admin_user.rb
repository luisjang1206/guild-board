# frozen_string_literal: true

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

User.find_or_create_by!(email_address: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = :super_admin
end

puts "Admin user seeded: #{admin_email}"
