require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @task = tasks(:active_task)
    @deleted_task = tasks(:deleted_task)
  end

  # -- Validations --

  test "valid with required attributes" do
    task = Task.new(
      title: "New Task",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: board_columns(:todo)
    )
    assert task.valid?
  end

  test "invalid without title" do
    task = Task.new(
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: board_columns(:todo)
    )
    assert_not task.valid?
    assert task.errors[:title].any?
  end

  test "invalid with blank title" do
    @task.title = "  "
    assert_not @task.valid?
    assert @task.errors[:title].any?
  end

  test "invalid without creator_type" do
    @task.creator_type = nil
    assert_not @task.valid?
    assert @task.errors[:creator_type].any?
  end

  test "invalid with unrecognized creator_type" do
    @task.creator_type = "robot"
    assert_not @task.valid?
    assert @task.errors[:creator_type].any?
  end

  test "valid creator_type user" do
    @task.creator_type = "user"
    assert @task.valid?
  end

  test "valid creator_type agent" do
    @task.creator_type = "agent"
    assert @task.valid?
  end

  test "invalid without creator_id" do
    @task.creator_id = nil
    assert_not @task.valid?
    assert @task.errors[:creator_id].any?
  end

  # -- Enum: priority --

  test "default priority is low" do
    task = Task.new
    assert task.low?
  end

  test "priority low maps to 0" do
    @task.priority = :low
    assert @task.low?
    assert_equal 0, Task.priorities[:low]
  end

  test "priority medium maps to 1" do
    @task.priority = :medium
    assert @task.medium?
    assert_equal 1, Task.priorities[:medium]
  end

  test "priority high maps to 2" do
    @task.priority = :high
    assert @task.high?
    assert_equal 2, Task.priorities[:high]
  end

  # -- Scope: active --

  test "active scope excludes soft-deleted tasks" do
    active_ids = Task.active.pluck(:id)
    assert_includes active_ids, @task.id
    assert_not_includes active_ids, @deleted_task.id
  end

  test "active scope returns tasks with nil deleted_at" do
    Task.active.each do |task|
      assert_nil task.deleted_at
    end
  end

  # -- Soft delete / restore --

  test "soft_delete sets deleted_at" do
    assert_nil @task.deleted_at
    @task.soft_delete
    assert_not_nil @task.reload.deleted_at
  end

  test "soft_deleted? returns false for active task" do
    assert_not @task.soft_deleted?
  end

  test "soft_deleted? returns true for deleted task" do
    assert @deleted_task.soft_deleted?
  end

  test "restore clears deleted_at" do
    assert_not_nil @deleted_task.deleted_at
    @deleted_task.restore
    assert_nil @deleted_task.reload.deleted_at
  end

  test "restored task appears in active scope" do
    @deleted_task.restore
    assert_includes Task.active.pluck(:id), @deleted_task.id
  end

  # -- Associations --

  test "belongs to project" do
    assert_equal projects(:user_one_project), @task.project
  end

  test "belongs to board_column" do
    assert_equal board_columns(:todo), @task.board_column
  end

  test "has many checklists" do
    assert_includes @task.checklists, checklists(:task_checklist_1)
    assert_includes @task.checklists, checklists(:task_checklist_2)
  end

  test "has many comments" do
    assert_includes @task.comments, comments(:user_comment)
    assert_includes @task.comments, comments(:agent_comment)
  end

  test "has many task_labels" do
    assert_includes @task.task_labels, task_labels(:active_task_frontend)
  end

  test "has many labels through task_labels" do
    assert_includes @task.labels, labels(:frontend)
  end

  test "checklists are destroyed with task" do
    # Create a fresh task with checklists but no activity_log (avoids FK violation)
    task = Task.create!(
      title: "Destroy Me",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: board_columns(:backlog)
    )
    checklist = Checklist.create!(content: "To be removed", task: task)
    task.destroy
    assert_empty Checklist.where(id: checklist.id)
  end

  test "comments are destroyed with task" do
    task = Task.create!(
      title: "Comment Host",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: board_columns(:backlog)
    )
    comment = Comment.create!(content: "Going away", author_type: "user", author_id: "1", task: task)
    task.destroy
    assert_empty Comment.where(id: comment.id)
  end

  test "task_labels are destroyed with task" do
    task = Task.create!(
      title: "Label Host",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: board_columns(:backlog)
    )
    task_label = TaskLabel.create!(task: task, label: labels(:backend))
    task.destroy
    assert_empty TaskLabel.where(id: task_label.id)
  end

  # -- Positionable --

  test "includes Positionable" do
    assert Task.ancestors.include?(Positionable)
  end

  test "auto-assigns position on create within same board_column" do
    column = board_columns(:todo)
    max_existing = column.tasks.maximum(:position)
    new_task = Task.create!(
      title: "Positioned Task",
      creator_type: "user",
      creator_id: "1",
      project: projects(:user_one_project),
      board_column: column
    )
    assert_equal max_existing + 1, new_task.position
  end
end
