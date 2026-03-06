require "test_helper"

class ActivityLogTest < ActiveSupport::TestCase
  setup do
    @log = activity_logs(:task_created_log)
  end

  # -- Validations --

  test "valid with required attributes" do
    log = ActivityLog.new(
      project: projects(:user_one_project),
      actor_type: "user",
      actor_id: "1",
      action: "task_created"
    )
    assert log.valid?
  end

  test "invalid without actor_type" do
    log = ActivityLog.new(
      project: projects(:user_one_project),
      actor_id: "1",
      action: "task_created"
    )
    assert_not log.valid?
    assert log.errors[:actor_type].any?
  end

  test "invalid without actor_id" do
    log = ActivityLog.new(
      project: projects(:user_one_project),
      actor_type: "user",
      action: "task_created"
    )
    assert_not log.valid?
    assert log.errors[:actor_id].any?
  end

  test "invalid without action" do
    log = ActivityLog.new(
      project: projects(:user_one_project),
      actor_type: "user",
      actor_id: "1"
    )
    assert_not log.valid?
    assert log.errors[:action].any?
  end

  # -- Associations --

  test "belongs to project" do
    assert_equal projects(:user_one_project), @log.project
  end

  test "belongs to task (optional)" do
    assert_equal tasks(:active_task), @log.task
  end

  test "valid without task (task is optional)" do
    log = ActivityLog.new(
      project: projects(:user_one_project),
      actor_type: "user",
      actor_id: "1",
      action: "project_created"
    )
    assert log.valid?
  end

  # -- Readonly --

  test "readonly? returns false for new (unpersisted) record" do
    log = ActivityLog.new
    assert_not log.readonly?
  end

  test "readonly? returns true for persisted record" do
    assert @log.readonly?
  end

  test "update raises ActiveRecord::ReadOnlyRecord on persisted log" do
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      @log.update!(action: "tampered")
    end
  end

  test "destroy raises ActiveRecord::ReadOnlyRecord" do
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      @log.destroy
    end
  end

  test "record remains in database after failed destroy" do
    begin
      @log.destroy
    rescue ActiveRecord::ReadOnlyRecord
      # expected
    end
    assert ActivityLog.exists?(@log.id)
  end
end
