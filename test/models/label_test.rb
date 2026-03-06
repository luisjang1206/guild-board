require "test_helper"

class LabelTest < ActiveSupport::TestCase
  setup do
    @label = labels(:frontend)
  end

  # -- Validations --

  test "valid with name, color, and project" do
    label = Label.new(name: "Design", color: "#AABBCC", project: projects(:user_one_project))
    assert label.valid?
  end

  test "invalid without name" do
    label = Label.new(color: "#AABBCC", project: projects(:user_one_project))
    assert_not label.valid?
    assert label.errors[:name].any?
  end

  test "invalid with blank name" do
    @label.name = "  "
    assert_not @label.valid?
    assert @label.errors[:name].any?
  end

  test "invalid without color" do
    label = Label.new(name: "No Color", project: projects(:user_one_project))
    assert_not label.valid?
    assert label.errors[:color].any?
  end

  test "invalid with blank color" do
    @label.color = ""
    assert_not @label.valid?
    assert @label.errors[:color].any?
  end

  test "invalid with non-hex color format" do
    @label.color = "blue"
    assert_not @label.valid?
    assert @label.errors[:color].any?
  end

  test "invalid with hex color missing hash" do
    @label.color = "3B82F6"
    assert_not @label.valid?
    assert @label.errors[:color].any?
  end

  test "invalid with short hex color" do
    @label.color = "#3B82F"
    assert_not @label.valid?
    assert @label.errors[:color].any?
  end

  test "invalid with long hex color" do
    @label.color = "#3B82F600"
    assert_not @label.valid?
    assert @label.errors[:color].any?
  end

  test "valid with uppercase hex color" do
    @label.color = "#AABBCC"
    assert @label.valid?
  end

  test "valid with lowercase hex color" do
    @label.color = "#aabbcc"
    assert @label.valid?
  end

  test "valid with mixed case hex color" do
    @label.color = "#aAbBcC"
    assert @label.valid?
  end

  test "invalid without project" do
    label = Label.new(name: "Orphan", color: "#123456")
    assert_not label.valid?
    assert label.errors[:project].any?
  end

  # -- Associations --

  test "belongs to project" do
    assert_equal projects(:user_one_project), @label.project
  end

  test "has many task_labels" do
    assert_includes @label.task_labels, task_labels(:active_task_frontend)
  end

  test "has many tasks through task_labels" do
    assert_includes @label.tasks, tasks(:active_task)
  end

  test "task_labels destroyed when label is destroyed" do
    task_label_ids = @label.task_labels.pluck(:id)
    @label.destroy
    assert_empty TaskLabel.where(id: task_label_ids)
  end
end
