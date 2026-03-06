require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:user_comment)
  end

  # -- Validations --

  test "valid with required attributes" do
    comment = Comment.new(
      content: "Looks good.",
      author_type: "user",
      author_id: "1",
      task: tasks(:active_task)
    )
    assert comment.valid?
  end

  test "invalid without content" do
    @comment.content = nil
    assert_not @comment.valid?
    assert @comment.errors[:content].any?
  end

  test "invalid with blank content" do
    @comment.content = "  "
    assert_not @comment.valid?
    assert @comment.errors[:content].any?
  end

  test "invalid without author_type" do
    @comment.author_type = nil
    assert_not @comment.valid?
    assert @comment.errors[:author_type].any?
  end

  test "invalid with unrecognized author_type" do
    @comment.author_type = "bot"
    assert_not @comment.valid?
    assert @comment.errors[:author_type].any?
  end

  test "valid author_type user" do
    @comment.author_type = "user"
    assert @comment.valid?
  end

  test "valid author_type agent" do
    @comment.author_type = "agent"
    assert @comment.valid?
  end

  test "invalid without author_id" do
    @comment.author_id = nil
    assert_not @comment.valid?
    assert @comment.errors[:author_id].any?
  end

  test "invalid with blank author_id" do
    @comment.author_id = ""
    assert_not @comment.valid?
    assert @comment.errors[:author_id].any?
  end

  test "invalid without task" do
    comment = Comment.new(content: "Orphaned", author_type: "user", author_id: "1")
    assert_not comment.valid?
    assert comment.errors[:task].any?
  end

  # -- Associations --

  test "belongs to task" do
    assert_equal tasks(:active_task), @comment.task
  end

  test "agent_comment has author_type agent" do
    assert_equal "agent", comments(:agent_comment).author_type
  end

  test "user_comment has author_type user" do
    assert_equal "user", @comment.author_type
  end
end
