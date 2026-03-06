# frozen_string_literal: true

require "test_helper"

class ChecklistBroadcastTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  setup do
    @task = tasks(:active_task)
    @detail_stream = stream_name_for([ @task, :detail ])
    @board_stream = stream_name_for([ @task.project, :board ])
  end

  test "broadcasts append to detail stream on create" do
    perform_enqueued_jobs do
      assert_broadcasts(@detail_stream, 1) do
        Checklist.create!(content: "Broadcast item", task: @task)
      end
    end
  end

  test "broadcasts replace to detail stream on update" do
    checklist = checklists(:task_checklist_1)
    perform_enqueued_jobs do
      assert_broadcasts(@detail_stream, 1) do
        checklist.update!(completed: true)
      end
    end
  end

  test "broadcasts remove from detail stream on destroy" do
    checklist = checklists(:task_checklist_1)
    assert_broadcasts(@detail_stream, 1) do
      checklist.destroy
    end
  end

  test "broadcasts task card refresh to board on change" do
    perform_enqueued_jobs do
      assert_broadcasts(@board_stream, 1) do
        Checklist.create!(content: "Board refresh item", task: @task)
      end
    end
  end

  private

  def stream_name_for(streamable)
    Turbo::StreamsChannel.send(:stream_name_from, streamable)
  end
end
