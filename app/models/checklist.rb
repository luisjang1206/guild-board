class Checklist < ApplicationRecord
  include Positionable
  positionable scope: :task_id

  belongs_to :task

  validates :content, presence: true
end
