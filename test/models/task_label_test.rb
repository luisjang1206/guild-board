require "test_helper"

class TaskLabelTest < ActiveSupport::TestCase
  setup do
    @task_label = task_labels(:active_task_frontend)
  end

  # -- Validations --

  test "valid with task and label" do
    task_label = TaskLabel.new(task: tasks(:active_task), label: labels(:backend))
    assert task_label.valid?
  end

  test "invalid without task" do
    task_label = TaskLabel.new(label: labels(:frontend))
    assert_not task_label.valid?
    assert task_label.errors[:task].any?
  end

  test "invalid without label" do
    task_label = TaskLabel.new(task: tasks(:active_task))
    assert_not task_label.valid?
    assert task_label.errors[:label].any?
  end

  test "invalid when same label applied to the same task twice" do
    duplicate = TaskLabel.new(
      task: tasks(:active_task),
      label: labels(:frontend)
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:label_id].any?
  end

  test "same label can be applied to different tasks" do
    # frontend label is on active_task; it should be valid on deleted_task
    task_label = TaskLabel.new(task: tasks(:deleted_task), label: labels(:frontend))
    assert task_label.valid?
  end

  test "same task can have different labels" do
    task_label = TaskLabel.new(task: tasks(:active_task), label: labels(:bugfix))
    assert task_label.valid?
  end

  # -- Associations --

  test "belongs to task" do
    assert_equal tasks(:active_task), @task_label.task
  end

  test "belongs to label" do
    assert_equal labels(:frontend), @task_label.label
  end
end
