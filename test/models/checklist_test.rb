require "test_helper"

class ChecklistTest < ActiveSupport::TestCase
  setup do
    @checklist = checklists(:task_checklist_1)
  end

  # -- Validations --

  test "valid with content and task" do
    checklist = Checklist.new(content: "Review PR", task: tasks(:active_task))
    assert checklist.valid?
  end

  test "invalid without content" do
    checklist = Checklist.new(task: tasks(:active_task))
    assert_not checklist.valid?
    assert checklist.errors[:content].any?
  end

  test "invalid with blank content" do
    @checklist.content = "  "
    assert_not @checklist.valid?
    assert @checklist.errors[:content].any?
  end

  test "invalid without task" do
    checklist = Checklist.new(content: "Orphaned item")
    assert_not checklist.valid?
    assert checklist.errors[:task].any?
  end

  # -- Associations --

  test "belongs to task" do
    assert_equal tasks(:active_task), @checklist.task
  end

  # -- Default completed state --

  test "fixture task_checklist_1 is not completed" do
    assert_not @checklist.completed
  end

  test "fixture task_checklist_2 is completed" do
    assert checklists(:task_checklist_2).completed
  end

  # -- Positionable --

  test "includes Positionable" do
    assert Checklist.ancestors.include?(Positionable)
  end

  test "auto-assigns next position within same task on create" do
    task = tasks(:active_task)
    max_existing = task.checklists.maximum(:position)
    new_item = Checklist.create!(content: "New item", task: task)
    assert_equal max_existing + 1, new_item.position
  end

  test "positions are scoped per task" do
    # deleted_task has no checklists, so first checklist should get position 0
    new_item = Checklist.create!(content: "First item", task: tasks(:deleted_task))
    assert_equal 0, new_item.position
  end
end
