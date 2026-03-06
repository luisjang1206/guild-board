# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_project
  before_action :set_task

  def create
    authorize @project, :update?
    @comment = @task.comments.build(comment_params)
    @comment.author_type = "user"
    @comment.author_id = Current.user.id.to_s
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_task_path(@project, @task) }
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def comment_params
    params.expect(comment: [ :content ])
  end
end
