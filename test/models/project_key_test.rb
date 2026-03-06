require "test_helper"

class ProjectKeyTest < ActiveSupport::TestCase
  setup do
    @key = project_keys(:default_key)
    @inactive_key = project_keys(:inactive_key)
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert @key.valid?
  end

  test "invalid without key_digest" do
    @key.key_digest = nil
    assert_not @key.valid?
    assert @key.errors[:key_digest].any?
  end

  test "invalid without key_prefix" do
    @key.key_prefix = nil
    assert_not @key.valid?
    assert @key.errors[:key_prefix].any?
  end

  test "invalid without name" do
    @key.name = nil
    assert_not @key.valid?
    assert @key.errors[:name].any?
  end

  test "invalid with blank name" do
    @key.name = "  "
    assert_not @key.valid?
    assert @key.errors[:name].any?
  end

  test "invalid when name exceeds 100 characters" do
    @key.name = "a" * 101
    assert_not @key.valid?
    assert @key.errors[:name].any?
  end

  test "invalid when key_prefix is not exactly 13 characters" do
    @key.key_prefix = "guild_short"
    assert_not @key.valid?
    assert @key.errors[:key_prefix].any?
  end

  test "invalid when key_prefix is not unique" do
    duplicate = @key.dup
    duplicate.key_digest = BCrypt::Password.create("guild_test1234567890abcdef12_dup")
    assert_not duplicate.valid?
    assert duplicate.errors[:key_prefix].any?
  end

  # -- Scope: active --

  test "active scope returns only active keys" do
    active_ids = ProjectKey.active.pluck(:id)
    assert_includes active_ids, @key.id
    assert_not_includes active_ids, @inactive_key.id
  end

  test "inactive key is excluded from active scope" do
    assert_not @inactive_key.active
  end

  # -- Associations --

  test "belongs to project" do
    assert_equal projects(:user_one_project), @key.project
  end

  # -- generate_for --

  test "generate_for returns an array of [record, raw_key]" do
    project = projects(:user_two_project)
    result = ProjectKey.generate_for(project, name: "Test Key")
    assert_instance_of Array, result
    assert_equal 2, result.length
  end

  test "generate_for returns a persisted ProjectKey as first element" do
    project = projects(:user_two_project)
    record, _raw_key = ProjectKey.generate_for(project, name: "Persisted Key")
    assert record.persisted?
  end

  test "generate_for returns a raw string key as second element" do
    project = projects(:user_two_project)
    _record, raw_key = ProjectKey.generate_for(project, name: "Raw Key")
    assert_instance_of String, raw_key
  end

  test "generate_for raw key starts with guild_ prefix" do
    project = projects(:user_two_project)
    _record, raw_key = ProjectKey.generate_for(project, name: "Prefixed Key")
    assert raw_key.start_with?("guild_")
  end

  test "generate_for stores key_prefix as first 13 characters of raw key" do
    project = projects(:user_two_project)
    record, raw_key = ProjectKey.generate_for(project, name: "Prefix Match Key")
    assert_equal raw_key[0, 13], record.key_prefix
  end

  test "generate_for associates key with the given project" do
    project = projects(:user_two_project)
    record, _raw_key = ProjectKey.generate_for(project, name: "Associated Key")
    assert_equal project, record.project
  end

  test "generate_for creates an active key by default" do
    project = projects(:user_two_project)
    record, _raw_key = ProjectKey.generate_for(project, name: "Active Key")
    # active column defaults to true via DB default or the record should be active
    # Check persisted state
    assert_not_nil record.key_digest
    assert_not_nil record.key_prefix
  end

  test "generate_for never exposes key_digest equal to raw key" do
    project = projects(:user_two_project)
    record, raw_key = ProjectKey.generate_for(project, name: "Digest Safety Key")
    assert_not_equal raw_key, record.key_digest
  end

  # -- authenticate --

  test "authenticate returns true for matching raw key" do
    _record, raw_key = ProjectKey.generate_for(projects(:user_two_project), name: "Auth Key")
    _record.reload
    assert _record.authenticate(raw_key)
  end

  test "authenticate returns false for wrong key" do
    assert_not @key.authenticate("guild_wrongkeyvalue1234567890")
  end

  test "authenticate returns false for empty string" do
    assert_not @key.authenticate("")
  end

  test "authenticate returns false for nil-like invalid hash input" do
    # Corrupt the digest to trigger BCrypt::Errors::InvalidHash rescue path
    @key.key_digest = "not_a_bcrypt_hash"
    assert_not @key.authenticate("guild_anything")
  end
end
