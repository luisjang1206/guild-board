class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy

enum :role, { user: 0, admin: 1, super_admin: 2 }, default: :user

validates :email_address, uniqueness: true
validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

generates_token_for :email_confirmation, expires_in: 24.hours do
  email_address
end

generates_token_for :magic_link, expires_in: 5.minutes do
  updated_at.to_f
end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
