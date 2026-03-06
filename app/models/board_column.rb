class BoardColumn < ApplicationRecord
  include Positionable
  include ActionView::RecordIdentifier
  positionable scope: :project_id

  belongs_to :project
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  after_create_commit -> {
    broadcast_before_to(
      [ project, :board ],
      target: "add-column-btn",
      partial: "board_columns/column",
      locals: { column: self, project: project, tasks: [] }
    )
  }

  after_update_commit -> {
    broadcast_replace_later_to(
      [ project, :board ],
      target: dom_id(self),
      partial: "board_columns/column",
      locals: { column: self, project: project, tasks: active_tasks }
    )
  }

  after_destroy_commit -> {
    broadcast_remove_to(
      [ project, :board ],
      target: dom_id(self)
    )
  }

  def active_tasks(filters = {})
    result = tasks.select { |t| t.deleted_at.nil? }
    result = result.select { |t| t.priority == filters[:priority] } if filters[:priority].present?
    result = result.select { |t| t.labels.any? { |l| l.id == filters[:label_id].to_i } } if filters[:label_id].present?
    result = result.select { |t| t.creator_type == filters[:creator_type] } if filters[:creator_type].present?
    result.sort_by(&:position)
  end
end
