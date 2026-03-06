class Task < ApplicationRecord
  include Positionable
  positionable scope: :board_column_id

  belongs_to :project
  belongs_to :board_column

  has_many :checklists, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :task_labels, dependent: :destroy
  has_many :labels, through: :task_labels

  enum :priority, { low: 0, medium: 1, high: 2 }, default: :low

  scope :active, -> { where(deleted_at: nil) }

  validates :title, presence: true
  validates :creator_type, presence: true, inclusion: { in: %w[user agent] }
  validates :creator_id, presence: true

  def soft_delete
    update_column(:deleted_at, Time.current)
  end

  def restore
    update_column(:deleted_at, nil)
  end

  def soft_deleted?
    deleted_at.present?
  end
end
