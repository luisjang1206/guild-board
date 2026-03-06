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

  def move_to_column(new_column_id, new_position)
    new_column_id = new_column_id.to_i
    new_position = new_position.to_i

    transaction do
      if board_column_id != new_column_id
        # Remove from old column: shift down items after current position
        self.class.where(board_column_id: board_column_id, deleted_at: nil)
          .where("position > ?", position)
          .where.not(id: id)
          .update_all("position = position - 1")

        # Insert into new column: shift up items at and after target position
        self.class.where(board_column_id: new_column_id, deleted_at: nil)
          .where("position >= ?", new_position)
          .where.not(id: id)
          .update_all("position = position + 1")

        update_columns(board_column_id: new_column_id, position: new_position)
      else
        move_to_position(new_position)
      end
    end
  end
end
