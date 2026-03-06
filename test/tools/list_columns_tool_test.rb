# frozen_string_literal: true

require "test_helper"

class ListColumnsToolTest < ActiveSupport::TestCase
  setup do
    Current.project = projects(:user_one_project)
    Current.agent_name = "test-agent"
  end

  teardown do
    Current.reset
  end

  test "returns all columns in position order" do
    tool = ListColumnsTool.new
    result = JSON.parse(tool.call)

    assert_equal 5, result.size
    positions = result.map { |c| c["position"] }
    assert_equal positions.sort, positions
    assert_equal "Backlog", result.first["name"]
    assert_equal "Done", result.last["name"]
  end

  test "each column includes id, name, position, tasks_count keys" do
    tool = ListColumnsTool.new
    result = JSON.parse(tool.call)

    result.each do |column|
      assert column.key?("id"), "Expected 'id' key in column hash"
      assert column.key?("name"), "Expected 'name' key in column hash"
      assert column.key?("position"), "Expected 'position' key in column hash"
      assert column.key?("tasks_count"), "Expected 'tasks_count' key in column hash"
    end
  end

  test "tasks_count counts only active tasks, excluding soft-deleted" do
    tool = ListColumnsTool.new
    result = JSON.parse(tool.call)

    # todo 칼럼에는 active_task(active)와 deleted_task(soft-deleted) 2개가 있지만
    # tasks_count는 active만 카운트하므로 1이어야 한다
    todo_column = result.find { |c| c["name"] == "Todo" }
    assert_not_nil todo_column
    assert_equal 1, todo_column["tasks_count"]
  end

  test "column with no tasks has tasks_count of zero" do
    tool = ListColumnsTool.new
    result = JSON.parse(tool.call)

    # done 칼럼에는 fixture 태스크가 없으므로 0이어야 한다
    done_column = result.find { |c| c["name"] == "Done" }
    assert_not_nil done_column
    assert_equal 0, done_column["tasks_count"]
  end
end
