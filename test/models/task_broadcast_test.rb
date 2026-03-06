# frozen_string_literal: true

require "test_helper"

class TaskBroadcastTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  setup do
    @project = projects(:user_one_project)
    @column = board_columns(:backlog)
    @stream = stream_name_for([@project, :board])
  end

  test "broadcasts append on create" do
    perform_enqueued_jobs do
      assert_broadcasts(@stream, 1) do
        Task.create!(
          title: "Broadcast Test",
          creator_type: "user",
          creator_id: "1",
          project: @project,
          board_column: @column
        )
      end
    end
  end

  test "broadcasts replace on update" do
    task = tasks(:active_task)
    stream = stream_name_for([task.project, :board])
    perform_enqueued_jobs do
      assert_broadcasts(stream, 1) do
        task.update!(title: "Updated Title")
      end
    end
  end

  test "broadcasts remove on soft_delete" do
    task = tasks(:active_task)
    stream = stream_name_for([task.project, :board])
    assert_broadcasts(stream, 1) do
      task.soft_delete
    end
  end

  test "broadcasts replace on restore" do
    task = tasks(:deleted_task)
    stream = stream_name_for([task.project, :board])
    perform_enqueued_jobs do
      assert_broadcasts(stream, 1) do
        task.restore
      end
    end
  end

  private

  def stream_name_for(streamable)
    Turbo::StreamsChannel.send(:stream_name_from, streamable)
  end
end
