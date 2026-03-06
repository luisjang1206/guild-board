class Label < ApplicationRecord
  belongs_to :project

  has_many :task_labels, dependent: :destroy
  has_many :tasks, through: :task_labels

  validates :name, presence: true
  validates :color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid hex color (e.g., #FF0000)" }
end
