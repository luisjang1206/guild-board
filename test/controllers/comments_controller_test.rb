# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    @task       = tasks(:active_task)
  end

  # --- create ---

  test "create redirects unauthenticated user to login" do
    post project_task_comments_url(@project, @task),
      params: { comment: { content: "A new comment" } }
    assert_redirected_to new_session_path
  end

  test "create with valid params increases comment count" do
    sign_in_as @user
    assert_difference("Comment.count", 1) do
      post project_task_comments_url(@project, @task),
        params: { comment: { content: "A new comment" } }
    end
  end

  test "create sets author_type to user" do
    sign_in_as @user
    post project_task_comments_url(@project, @task),
      params: { comment: { content: "Authored comment" } }
    assert_equal "user", Comment.last.author_type
  end

  test "create sets author_id to current user id" do
    sign_in_as @user
    post project_task_comments_url(@project, @task),
      params: { comment: { content: "Authored comment" } }
    assert_equal @user.id.to_s, Comment.last.author_id
  end

  test "create redirects to task page on html request" do
    sign_in_as @user
    post project_task_comments_url(@project, @task),
      params: { comment: { content: "A new comment" } }
    assert_redirected_to project_task_path(@project, @task)
  end

  test "create with valid params and turbo_stream returns turbo_stream response" do
    sign_in_as @user
    post project_task_comments_url(@project, @task),
      params: { comment: { content: "Turbo comment" } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "create with invalid params returns 422" do
    sign_in_as @user
    assert_no_difference("Comment.count") do
      post project_task_comments_url(@project, @task),
        params: { comment: { content: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "create returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Comment.count") do
      post project_task_comments_url(@project, @task),
        params: { comment: { content: "Hijack comment" } }
    end
    assert_response :forbidden
  end
end
