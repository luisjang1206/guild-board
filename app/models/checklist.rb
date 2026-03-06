class Checklist < ApplicationRecord
  include Positionable
  include ActionView::RecordIdentifier
  positionable scope: :task_id

  belongs_to :task

  validates :content, presence: true

  after_create_commit -> {
    broadcast_append_later_to [ task, :detail ],
      target: "checklist-items",
      partial: "checklists/checklist_item",
      locals: { checklist: self, task: task, project: task.project }
  }

  after_update_commit -> {
    broadcast_replace_later_to [ task, :detail ],
      target: dom_id(self),
      partial: "checklists/checklist_item",
      locals: { checklist: self, task: task, project: task.project }
  }

  after_destroy_commit -> {
    broadcast_remove_to [ task, :detail ],
      target: dom_id(self)
  }

  after_commit -> {
    broadcast_replace_later_to [ task.project, :board ],
      target: "task_#{task.id}",
      partial: "tasks/task_card",
      locals: { task: task }
  }, on: [ :create, :update, :destroy ]
end
