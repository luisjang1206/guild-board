# frozen_string_literal: true

class TasksController < ApplicationController
  include ActivityLoggable

  before_action :set_project
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]

  def new
    @task = @project.tasks.build
    authorize @task
    @board_columns = @project.board_columns.order(:position)
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.creator_type = "user"
    @task.creator_id = Current.user.id.to_s
    authorize @task

    if @task.save
      log_activity(action: "task_created", task: @task, metadata: { title: [ nil, @task.title ], board_column: [ nil, @task.board_column.name ] })
      redirect_to project_board_path(@project)
    else
      @board_columns = @project.board_columns.order(:position)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @task
  end

  def edit
    authorize @task
    @board_columns = @project.board_columns.order(:position)
  end

  def update
    authorize @task

    if @task.update(task_params)
      log_activity(action: "task_updated", task: @task, metadata: @task.saved_changes.except("updated_at"))
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_board_path(@project) }
      end
    else
      @board_columns = @project.board_columns.order(:position)
      render :edit, status: :unprocessable_entity
    end
  end

  def move
    @task = @project.tasks.find(params[:id])
    authorize @task, :update?
    old_column_name = @task.board_column.name
    @task.move_to_column(params[:board_column_id], params[:position])
    @task.reload
    new_column_name = @task.board_column.name

    log_activity(action: "task_moved", task: @task, metadata: { board_column: [ old_column_name, new_column_name ] })

    Turbo::StreamsChannel.broadcast_remove_to(
      [ @project, :board ],
      target: ActionView::RecordIdentifier.dom_id(@task)
    )
    Turbo::StreamsChannel.broadcast_append_to(
      [ @project, :board ],
      target: "board_column_#{@task.board_column_id}_tasks",
      partial: "tasks/task_card",
      locals: { task: @task }
    )

    head :ok
  rescue ActiveRecord::RecordInvalid => e
    head :unprocessable_entity
  end

  def destroy
    authorize @task
    log_activity(action: "task_deleted", task: @task, metadata: { title: @task.title })
    @task.soft_delete
    redirect_to project_board_path(@project), notice: t("tasks.destroyed")
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.includes(:board_column, :checklists, :comments, :labels, :activity_logs).find(params[:id])
  end

  def task_params
    params.expect(task: [ :title, :description, :priority, :board_column_id, label_ids: [] ])
  end
end
