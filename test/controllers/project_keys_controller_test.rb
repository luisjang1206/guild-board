require "test_helper"

class ProjectKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @other_user = users(:admin)
    @project = projects(:user_one_project)
    @other_project = projects(:user_two_project)
    @project_key = project_keys(:default_key)
    @inactive_key = project_keys(:inactive_key)
  end

  # --- create ---

  test "create redirects unauthenticated user to login" do
    post project_project_keys_url(@project), params: { project_key: { name: "API Key" } }
    assert_redirected_to new_session_path
  end

  test "create by owner generates a new key and redirects with flash" do
    sign_in_as @user
    assert_difference("ProjectKey.count", 1) do
      post project_project_keys_url(@project), params: { project_key: { name: "New API Key" } }
    end
    assert_redirected_to project_url(@project)
    # raw key is exposed once in flash[:project_key]
    assert flash[:project_key].present?
    assert flash[:project_key].start_with?("guild_")
    # key_prefix is stored alongside so the view can match exactly the right key
    assert flash[:project_key_prefix].present?
    assert_equal flash[:project_key][0, 13], flash[:project_key_prefix]
  end

  # Non-owner cannot access another user's project — set_project uses
  # Current.user.projects.find(...) which raises RecordNotFound (404).
  test "create by non-owner returns 404" do
    sign_in_as @other_user
    assert_no_difference("ProjectKey.count") do
      post project_project_keys_url(@project), params: { project_key: { name: "Stolen Key" } }
    end
    assert_response :not_found
  end

  # --- destroy ---

  test "destroy redirects unauthenticated user to login" do
    delete project_project_key_url(@project, @project_key)
    assert_redirected_to new_session_path
  end

  test "destroy by owner deletes the key and redirects" do
    sign_in_as @user
    assert_difference("ProjectKey.count", -1) do
      delete project_project_key_url(@project, @project_key)
    end
    assert_redirected_to project_url(@project)
  end

  test "destroy by non-owner returns 404" do
    sign_in_as @other_user
    assert_no_difference("ProjectKey.count") do
      delete project_project_key_url(@project, @project_key)
    end
    assert_response :not_found
  end

  # --- toggle_active ---

  test "toggle_active redirects unauthenticated user to login" do
    patch toggle_active_project_project_key_url(@project, @project_key)
    assert_redirected_to new_session_path
  end

  test "toggle_active by owner flips active to false and redirects" do
    sign_in_as @user
    # @project_key (default_key) starts as active: true
    patch toggle_active_project_project_key_url(@project, @project_key)
    assert_redirected_to project_url(@project)
    assert_equal false, @project_key.reload.active
  end

  test "toggle_active by owner flips active to true and redirects" do
    sign_in_as @user
    # @inactive_key starts as active: false
    patch toggle_active_project_project_key_url(@project, @inactive_key)
    assert_redirected_to project_url(@project)
    assert_equal true, @inactive_key.reload.active
  end

  test "toggle_active by non-owner returns 404" do
    sign_in_as @other_user
    patch toggle_active_project_project_key_url(@project, @project_key)
    assert_response :not_found
  end

  # --- regenerate ---

  test "regenerate redirects unauthenticated user to login" do
    post regenerate_project_project_key_url(@project, @project_key)
    assert_redirected_to new_session_path
  end

  test "regenerate by owner deactivates old key and creates a new one" do
    sign_in_as @user
    assert_difference("ProjectKey.count", 1) do
      post regenerate_project_project_key_url(@project, @project_key)
    end
    assert_redirected_to project_url(@project)
    # Old key is deactivated
    assert_equal false, @project_key.reload.active
    # Raw key for the new key is exposed in flash
    assert flash[:project_key].present?
    assert flash[:project_key].start_with?("guild_")
    # prefix is stored so the view matches exactly the newly generated key
    assert flash[:project_key_prefix].present?
    assert_equal flash[:project_key][0, 13], flash[:project_key_prefix]
  end

  test "regenerate new key name contains 'regenerated'" do
    sign_in_as @user
    post regenerate_project_project_key_url(@project, @project_key)
    new_key = @project.project_keys.order(created_at: :desc).first
    assert_match(/regenerated/, new_key.name)
  end

  test "regenerate by non-owner returns 404" do
    sign_in_as @other_user
    assert_no_difference("ProjectKey.count") do
      post regenerate_project_project_key_url(@project, @project_key)
    end
    assert_response :not_found
  end
end
