# frozen_string_literal: true

class AddMissingIndexesForPerformance < ActiveRecord::Migration[8.1]
  def change
    # activity_logs: ORDER BY created_at DESC is the primary query pattern
    add_index :activity_logs, :created_at

    # comments: ORDER BY created_at ASC for task detail view
    add_index :comments, :created_at
  end
end
