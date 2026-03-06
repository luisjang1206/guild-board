# frozen_string_literal: true

require "test_helper"

class McpAuthenticationTest < ActiveSupport::TestCase
  # default_key: guild_test1234567890abcdef12 (active, user_one_project)
  # inactive_key: guild_inac1234567890abcdef12 (inactive, user_one_project)
  VALID_RAW_KEY    = "guild_test1234567890abcdef12"
  INACTIVE_RAW_KEY = "guild_inac1234567890abcdef12"

  # FastMcp::Tool は initialize(headers: {}) を受け取るので stub 不要
  def build_tool(headers = {})
    ListColumnsTool.new(headers: headers)
  end

  # テスト環境のキャッシュは :null_store のため、rate limit テストでは
  # MemoryStore を一時的に使用する
  def with_memory_cache
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original
  end

  teardown do
    Current.reset
    Rails.cache.clear
  end

  # ---------------------------------------------------------------------------
  # 인증 성공 케이스
  # ---------------------------------------------------------------------------

  test "valid key authenticates successfully" do
    tool = build_tool("X-Project-Key" => VALID_RAW_KEY)
    assert tool.send(:authenticate_project_key!)
  end

  test "sets Current.project on successful authentication" do
    tool = build_tool("X-Project-Key" => VALID_RAW_KEY)
    tool.send(:authenticate_project_key!)
    assert_equal projects(:user_one_project), Current.project
  end

  test "sets Current.agent_name to unknown-agent when header is absent" do
    tool = build_tool("X-Project-Key" => VALID_RAW_KEY)
    tool.send(:authenticate_project_key!)
    assert_equal "unknown-agent", Current.agent_name
  end

  test "sets Current.agent_name from X-Agent-Name header" do
    tool = build_tool("X-Project-Key" => VALID_RAW_KEY, "X-Agent-Name" => "my-bot")
    tool.send(:authenticate_project_key!)
    assert_equal "my-bot", Current.agent_name
  end

  # ---------------------------------------------------------------------------
  # 인증 실패 케이스
  # ---------------------------------------------------------------------------

  test "fails when X-Project-Key header is absent" do
    tool = build_tool
    assert_not tool.send(:authenticate_project_key!)
  end

  test "fails when X-Project-Key header is blank string" do
    tool = build_tool("X-Project-Key" => "")
    assert_not tool.send(:authenticate_project_key!)
  end

  test "fails with wrong raw key value" do
    tool = build_tool("X-Project-Key" => "guild_test123WRONGKEYWRONG")
    assert_not tool.send(:authenticate_project_key!)
  end

  test "fails with inactive key" do
    tool = build_tool("X-Project-Key" => INACTIVE_RAW_KEY)
    assert_not tool.send(:authenticate_project_key!)
  end

  test "fails with completely unknown key prefix" do
    tool = build_tool("X-Project-Key" => "guild_unkn123xxxxxxxxxxxxxxxxxxxxx")
    assert_not tool.send(:authenticate_project_key!)
  end

  test "fails when key is shorter than required prefix length" do
    tool = build_tool("X-Project-Key" => "guild_short")
    assert_not tool.send(:authenticate_project_key!)
  end

  test "fails when key is exactly prefix length with no payload" do
    # 13자 정확히 = prefix만 존재, payload 없음 → 인증 실패해야 한다
    tool = build_tool("X-Project-Key" => "guild_test123")
    assert_not tool.send(:authenticate_project_key!)
  end

  # ---------------------------------------------------------------------------
  # last_used_at 업데이트
  # ---------------------------------------------------------------------------

  test "updates last_used_at when it was nil" do
    project_key = project_keys(:default_key)
    project_key.update_column(:last_used_at, nil)

    build_tool("X-Project-Key" => VALID_RAW_KEY).send(:authenticate_project_key!)

    assert_not_nil project_key.reload.last_used_at
  end

  test "updates last_used_at when it was older than 5 minutes" do
    project_key = project_keys(:default_key)
    old_time = 6.minutes.ago
    project_key.update_column(:last_used_at, old_time)

    build_tool("X-Project-Key" => VALID_RAW_KEY).send(:authenticate_project_key!)

    assert project_key.reload.last_used_at > old_time
  end

  test "does not update last_used_at when it was set within the last 5 minutes" do
    project_key = project_keys(:default_key)
    recent_time = 2.minutes.ago
    project_key.update_column(:last_used_at, recent_time)

    build_tool("X-Project-Key" => VALID_RAW_KEY).send(:authenticate_project_key!)

    assert_in_delta recent_time, project_key.reload.last_used_at, 1.second
  end

  # ---------------------------------------------------------------------------
  # Rate Limit
  # 테스트 환경 캐시는 :null_store이므로 이 그룹에서만 MemoryStore로 교체한다
  # ---------------------------------------------------------------------------

  test "allows exactly 60 requests within the minute window" do
    with_memory_cache do
      tool = build_tool("X-Project-Key" => VALID_RAW_KEY)
      60.times do |i|
        Current.reset
        assert tool.send(:authenticate_project_key!), "Request #{i + 1} should be allowed within rate limit"
      end
    end
  end

  test "denies the 61st request within the same minute window" do
    with_memory_cache do
      tool = build_tool("X-Project-Key" => VALID_RAW_KEY)
      60.times { Current.reset; tool.send(:authenticate_project_key!) }

      Current.reset
      assert_not tool.send(:authenticate_project_key!), "61st request should be denied by rate limit"
    end
  end

  test "rate limit is tracked per key prefix independently" do
    with_memory_cache do
      # default_key의 prefix(guild_test123)로 한도를 소진한다
      tool = build_tool("X-Project-Key" => VALID_RAW_KEY)
      60.times { Current.reset; tool.send(:authenticate_project_key!) }

      # 완전히 다른 prefix는 독립적으로 허용되어야 한다
      assert tool.send(:rate_limit_ok?, "other_prefix")
    end
  end

  test "rate_limit_ok? returns true for a fresh prefix" do
    with_memory_cache do
      tool = build_tool
      assert tool.send(:rate_limit_ok?, "brand_new_prefix")
    end
  end

  test "rate_limit_ok? returns false after 60 increments for the same prefix" do
    with_memory_cache do
      tool = build_tool
      prefix = "some_prefix"

      59.times { tool.send(:rate_limit_ok?, prefix) }

      # 60번째는 허용
      assert tool.send(:rate_limit_ok?, prefix), "60th call should still be within the limit"

      # 61번째는 거부
      assert_not tool.send(:rate_limit_ok?, prefix), "61st call should exceed the rate limit"
    end
  end

  # ---------------------------------------------------------------------------
  # 실행 순서: Current 설정은 rate limit 체크 이전에 발생한다
  # ---------------------------------------------------------------------------

  test "Current.project is set even when rate limit is exceeded" do
    with_memory_cache do
      tool = build_tool("X-Project-Key" => VALID_RAW_KEY)

      # 60회 소진하여 다음 요청부터 rate limit 초과 상태로 만든다
      60.times { Current.reset; tool.send(:authenticate_project_key!) }

      Current.reset
      result = tool.send(:authenticate_project_key!)

      # authenticate_project_key! 은 false 를 반환하지만
      # Current.project 는 rate_limit_ok? 호출 이전에 이미 설정된다
      assert_not result
      assert_equal projects(:user_one_project), Current.project
    end
  end
end
