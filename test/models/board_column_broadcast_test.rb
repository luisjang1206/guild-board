# frozen_string_literal: true

require "test_helper"

class BoardColumnBroadcastTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  setup do
    @project = projects(:user_one_project)
    @stream = stream_name_for([@project, :board])
  end

  test "broadcasts before on create" do
    assert_broadcasts(@stream, 1) do
      BoardColumn.create!(name: "New Column", project: @project)
    end
  end

  test "broadcasts replace on update" do
    column = board_columns(:todo)
    perform_enqueued_jobs do
      assert_broadcasts(@stream, 1) do
        column.update!(name: "Renamed")
      end
    end
  end

  test "broadcasts remove on destroy" do
    column = board_columns(:done)
    assert_broadcasts(@stream, 1) do
      column.destroy
    end
  end

  private

  def stream_name_for(streamable)
    Turbo::StreamsChannel.send(:stream_name_from, streamable)
  end
end
