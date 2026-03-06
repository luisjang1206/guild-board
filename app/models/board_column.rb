class BoardColumn < ApplicationRecord
  include Positionable
  positionable scope: :project_id

  belongs_to :project
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
