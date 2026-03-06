require "test_helper"

class LabelsControllerTest < ActionDispatch::IntegrationTest
  # Route: /projects/:project_id/labels (resources :labels)
  # Authorization: all actions check `authorize @project, :update?`
  # set_project uses Project.find (no user scope) — non-owner reaches Pundit → 403

  setup do
    @user       = users(:regular)
    @other_user = users(:admin)
    @project    = projects(:user_one_project)
    @label      = labels(:frontend)
  end

  # -------------------------------------------------------------------------
  # index
  # -------------------------------------------------------------------------

  test "index redirects unauthenticated user to login" do
    get project_labels_url(@project)
    assert_redirected_to new_session_path
  end

  test "index returns success for project owner" do
    sign_in_as @user
    get project_labels_url(@project)
    assert_response :success
  end

  test "index returns 403 for non-owner" do
    sign_in_as @other_user
    get project_labels_url(@project)
    assert_response :forbidden
  end

  # -------------------------------------------------------------------------
  # create
  # -------------------------------------------------------------------------

  test "create redirects unauthenticated user to login" do
    post project_labels_url(@project),
      params: { label: { name: "Ops", color: "#123456" } }
    assert_redirected_to new_session_path
  end

  test "create with valid params increases Label count" do
    sign_in_as @user
    assert_difference("Label.count", 1) do
      post project_labels_url(@project),
        params: { label: { name: "Ops", color: "#123456" } }
    end
  end

  test "create with valid params creates label belonging to the project" do
    sign_in_as @user
    post project_labels_url(@project),
      params: { label: { name: "Ops", color: "#123456" } }
    assert_equal @project, Label.last.project
  end

  test "create with valid params and html redirects to index" do
    sign_in_as @user
    post project_labels_url(@project),
      params: { label: { name: "Ops", color: "#123456" } }
    assert_redirected_to project_labels_path(@project)
  end

  test "create with valid params and turbo_stream returns turbo_stream response" do
    sign_in_as @user
    post project_labels_url(@project),
      params: { label: { name: "Ops", color: "#123456" } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "create with invalid params renders index with 422" do
    sign_in_as @user
    assert_no_difference("Label.count") do
      post project_labels_url(@project),
        params: { label: { name: "", color: "#123456" } }
    end
    assert_response :unprocessable_entity
  end

  test "create with invalid hex color renders index with 422" do
    sign_in_as @user
    assert_no_difference("Label.count") do
      post project_labels_url(@project),
        params: { label: { name: "Bad Color", color: "not-a-color" } }
    end
    assert_response :unprocessable_entity
  end

  test "create returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Label.count") do
      post project_labels_url(@project),
        params: { label: { name: "Hijack", color: "#ABCDEF" } }
    end
    assert_response :forbidden
  end

  # -------------------------------------------------------------------------
  # edit
  # -------------------------------------------------------------------------

  test "edit redirects unauthenticated user to login" do
    get edit_project_label_url(@project, @label)
    assert_redirected_to new_session_path
  end

  test "edit returns success for project owner" do
    sign_in_as @user
    get edit_project_label_url(@project, @label)
    assert_response :success
  end

  test "edit returns 403 for non-owner" do
    sign_in_as @other_user
    get edit_project_label_url(@project, @label)
    assert_response :forbidden
  end

  # -------------------------------------------------------------------------
  # update
  # -------------------------------------------------------------------------

  test "update redirects unauthenticated user to login" do
    patch project_label_url(@project, @label),
      params: { label: { name: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "update with valid params updates the label" do
    sign_in_as @user
    patch project_label_url(@project, @label),
      params: { label: { name: "Renamed", color: "#AABBCC" } }
    assert_equal "Renamed", @label.reload.name
    assert_equal "#AABBCC", @label.reload.color
  end

  test "update with valid params and turbo_stream returns turbo_stream response" do
    sign_in_as @user
    patch project_label_url(@project, @label),
      params: { label: { name: "Turbo Rename", color: "#AABBCC" } },
      as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "update with invalid params renders edit with 422" do
    sign_in_as @user
    patch project_label_url(@project, @label),
      params: { label: { name: "" } }
    assert_response :unprocessable_entity
    assert_not_equal "", @label.reload.name
  end

  test "update returns 403 for non-owner" do
    sign_in_as @other_user
    original_name = @label.name
    patch project_label_url(@project, @label),
      params: { label: { name: "Hacked" } }
    assert_response :forbidden
    assert_equal original_name, @label.reload.name
  end

  # -------------------------------------------------------------------------
  # destroy
  # -------------------------------------------------------------------------

  test "destroy redirects unauthenticated user to login" do
    delete project_label_url(@project, @label)
    assert_redirected_to new_session_path
  end

  test "destroy decreases Label count" do
    sign_in_as @user
    assert_difference("Label.count", -1) do
      delete project_label_url(@project, @label)
    end
  end

  test "destroy removes the label from the database" do
    sign_in_as @user
    label_id = @label.id
    delete project_label_url(@project, @label)
    assert_empty Label.where(id: label_id)
  end

  test "destroy with html redirects to index" do
    sign_in_as @user
    delete project_label_url(@project, @label)
    assert_redirected_to project_labels_path(@project)
  end

  test "destroy with turbo_stream returns turbo_stream response" do
    sign_in_as @user
    delete project_label_url(@project, @label), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "destroy returns 403 for non-owner" do
    sign_in_as @other_user
    assert_no_difference("Label.count") do
      delete project_label_url(@project, @label)
    end
    assert_response :forbidden
  end
end
