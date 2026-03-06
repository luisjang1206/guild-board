# frozen_string_literal: true

class AddCommentTool < ApplicationTool
  description "태스크에 코멘트를 추가합니다"

  arguments do
    required(:task_id).filled(:integer).description("태스크 ID")
    required(:content).filled(:string).description("코멘트 내용")
  end

  def call(task_id:, content:)
    task = Current.project.tasks.active.find_by(id: task_id)
    return JSON.generate({ error: "태스크를 찾을 수 없습니다 (id: #{task_id})" }) unless task

    comment = task.comments.create!(
      content: content,
      author_type: "agent",
      author_id: Current.agent_name
    )

    JSON.generate({
      id: comment.id,
      content: comment.content,
      author_type: comment.author_type,
      author_id: comment.author_id,
      created_at: comment.created_at
    })
  end
end
