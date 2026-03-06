class ActivityLog < ApplicationRecord
  belongs_to :project
  belongs_to :task, optional: true

  validates :actor_type, presence: true
  validates :actor_id, presence: true
  validates :action, presence: true

  def readonly?
    persisted?
  end

  before_destroy { raise ActiveRecord::ReadOnlyRecord }
end
