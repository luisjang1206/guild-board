class Comment < ApplicationRecord
  belongs_to :task

  validates :content, presence: true
  validates :author_type, presence: true, inclusion: { in: %w[user agent] }
  validates :author_id, presence: true
end
