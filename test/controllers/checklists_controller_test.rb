# frozen_string_literal: true

require "test_helper"

class ChecklistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    @task       = tasks(:active_task)
    @checklist  = checklists(:task_checklist_1)
  end

  # --- create ---

  test "create redirects unauthenticated user to login" do
    post project_task_checklists_url(@project, @task),
      params: { checklist: { content: "New item" } }
    assert_redirected_to new_session_path
  end

  test "create with valid params increases checklist count" do
    sign_in_as @user
    assert_difference("Checklist.count", 1) do
      post project_task_checklists_url(@project, @task),
        params: { checklist: { content: "New checklist item" } }
    end
  end

  test "create with valid params redirects to task page" do
    sign_in_as @user
    post project_task_checklists_url(@project, @task),
      params: { checklist: { content: "New checklist item" } }
    assert_redirected_to project_task_path(@project, @task)
  end

  test "create with valid params and turbo_stream returns turbo_stream response" do
    sign_in_as @user
    post project_task_checklists_url(@project, @task),
      params: { checklist: { content: "Turbo item" } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "create with invalid params returns 422" do
    sign_in_as @user
    assert_no_difference("Checklist.count") do
      post project_task_checklists_url(@project, @task),
        params: { checklist: { content: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "create returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Checklist.count") do
      post project_task_checklists_url(@project, @task),
        params: { checklist: { content: "Hijack item" } }
    end
    assert_response :forbidden
  end

  # --- update ---

  test "update redirects unauthenticated user to login" do
    patch project_task_checklist_url(@project, @task, @checklist),
      params: { checklist: { completed: true } }
    assert_redirected_to new_session_path
  end

  test "update toggles completed to true" do
    sign_in_as @user
    # task_checklist_1 has completed: false
    patch project_task_checklist_url(@project, @task, @checklist),
      params: { checklist: { completed: true } }
    assert @checklist.reload.completed
  end

  test "update toggles completed to false" do
    sign_in_as @user
    completed_checklist = checklists(:task_checklist_2)
    # task_checklist_2 has completed: true
    patch project_task_checklist_url(@project, @task, completed_checklist),
      params: { checklist: { completed: false } }
    assert_not completed_checklist.reload.completed
  end

  test "update redirects to task page on html request" do
    sign_in_as @user
    patch project_task_checklist_url(@project, @task, @checklist),
      params: { checklist: { completed: true } }
    assert_redirected_to project_task_path(@project, @task)
  end

  test "update with turbo_stream returns turbo_stream response" do
    sign_in_as @user
    patch project_task_checklist_url(@project, @task, @checklist),
      params: { checklist: { completed: true } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "update returns 403 for non-owner" do
    sign_in_as @other_user
    patch project_task_checklist_url(@project, @task, @checklist),
      params: { checklist: { completed: true } }
    assert_response :forbidden
    assert_not @checklist.reload.completed
  end

  # --- destroy ---

  test "destroy redirects unauthenticated user to login" do
    delete project_task_checklist_url(@project, @task, @checklist)
    assert_redirected_to new_session_path
  end

  test "destroy decreases checklist count" do
    sign_in_as @user
    assert_difference("Checklist.count", -1) do
      delete project_task_checklist_url(@project, @task, @checklist)
    end
  end

  test "destroy redirects to task page on html request" do
    sign_in_as @user
    delete project_task_checklist_url(@project, @task, @checklist)
    assert_redirected_to project_task_path(@project, @task)
  end

  test "destroy with turbo_stream returns turbo_stream response" do
    sign_in_as @user
    delete project_task_checklist_url(@project, @task, @checklist),
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "destroy returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Checklist.count") do
      delete project_task_checklist_url(@project, @task, @checklist)
    end
    assert_response :forbidden
  end
end
