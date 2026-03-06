# frozen_string_literal: true

require "test_helper"

class ActivityLogJobTest < ActiveJob::TestCase
  setup do
    @project = projects(:user_one_project)
    @task = tasks(:active_task)
  end

  test "creates activity log record with all attributes" do
    assert_difference "ActivityLog.count", 1 do
      ActivityLogJob.perform_now(
        project_id: @project.id,
        task_id: @task.id,
        actor_type: "user",
        actor_id: "1",
        action: "task_created",
        metadata: { "title" => [ nil, "New Task" ] }
      )
    end

    log = ActivityLog.order(:created_at).last
    assert_equal @project.id, log.project_id
    assert_equal @task.id, log.task_id
    assert_equal "user", log.actor_type
    assert_equal "1", log.actor_id
    assert_equal "task_created", log.action
    assert_equal({ "title" => [ nil, "New Task" ] }, log.metadata)
  end

  test "creates activity log without task_id" do
    assert_difference "ActivityLog.count", 1 do
      ActivityLogJob.perform_now(
        project_id: @project.id,
        actor_type: "user",
        actor_id: "1",
        action: "column_created",
        metadata: { "name" => [ nil, "New Column" ] }
      )
    end

    log = ActivityLog.order(:created_at).last
    assert_nil log.task_id
  end

  test "creates activity log with agent actor_type" do
    assert_difference "ActivityLog.count", 1 do
      ActivityLogJob.perform_now(
        project_id: @project.id,
        task_id: @task.id,
        actor_type: "agent",
        actor_id: "test-agent",
        action: "comment_added",
        metadata: { "content" => "Agent comment" }
      )
    end

    log = ActivityLog.order(:created_at).last
    assert_equal "agent", log.actor_type
    assert_equal "test-agent", log.actor_id
  end

  test "creates activity log with empty metadata by default" do
    ActivityLogJob.perform_now(
      project_id: @project.id,
      actor_type: "user",
      actor_id: "1",
      action: "task_deleted"
    )

    log = ActivityLog.order(:created_at).last
    assert_equal({}, log.metadata)
  end

  test "raises error when actor_type is blank" do
    assert_raises(ActiveRecord::RecordInvalid) do
      ActivityLogJob.perform_now(
        project_id: @project.id,
        actor_type: "",
        actor_id: "1",
        action: "task_created"
      )
    end
  end

  test "raises error when actor_id is blank" do
    assert_raises(ActiveRecord::RecordInvalid) do
      ActivityLogJob.perform_now(
        project_id: @project.id,
        actor_type: "user",
        actor_id: "",
        action: "task_created"
      )
    end
  end

  test "raises error when action is blank" do
    assert_raises(ActiveRecord::RecordInvalid) do
      ActivityLogJob.perform_now(
        project_id: @project.id,
        actor_type: "user",
        actor_id: "1",
        action: ""
      )
    end
  end

  test "created log is readonly after persisting" do
    ActivityLogJob.perform_now(
      project_id: @project.id,
      actor_type: "user",
      actor_id: "1",
      action: "task_created"
    )

    log = ActivityLog.order(:created_at).last
    assert log.readonly?
  end

  test "queues on the default queue" do
    assert_equal "default", ActivityLogJob.new.queue_name
  end
end
