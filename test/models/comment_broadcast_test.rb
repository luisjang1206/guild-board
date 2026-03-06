# frozen_string_literal: true

require "test_helper"

class CommentBroadcastTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  setup do
    @task = tasks(:active_task)
    @stream = stream_name_for([ @task, :detail ])
  end

  test "broadcasts append on create" do
    perform_enqueued_jobs do
      assert_broadcasts(@stream, 1) do
        Comment.create!(
          content: "Broadcast comment",
          author_type: "user",
          author_id: "1",
          task: @task
        )
      end
    end
  end

  private

  def stream_name_for(streamable)
    Turbo::StreamsChannel.send(:stream_name_from, streamable)
  end
end
