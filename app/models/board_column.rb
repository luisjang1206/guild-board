class BoardColumn < ApplicationRecord
  include Positionable
  positionable scope: :project_id

  belongs_to :project
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  def active_tasks(filters = {})
    result = tasks.select { |t| t.deleted_at.nil? }
    result = result.select { |t| t.priority == filters[:priority] } if filters[:priority].present?
    result = result.select { |t| t.labels.any? { |l| l.id == filters[:label_id].to_i } } if filters[:label_id].present?
    result = result.select { |t| t.creator_type == filters[:creator_type] } if filters[:creator_type].present?
    result.sort_by(&:position)
  end
end
