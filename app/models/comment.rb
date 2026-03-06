class Comment < ApplicationRecord
  belongs_to :task

  validates :content, presence: true
  validates :author_type, presence: true, inclusion: { in: %w[user agent] }
  validates :author_id, presence: true

  after_create_commit -> {
    broadcast_append_later_to [ task, :detail ],
      target: "comments-list",
      partial: "comments/comment",
      locals: { comment: self }
  }
end
