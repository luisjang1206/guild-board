# frozen_string_literal: true

class TasksController < ApplicationController
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
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_board_path(@project) }
      end
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
    @task.move_to_column(params[:board_column_id], params[:position])
    head :ok
  rescue ActiveRecord::RecordInvalid => e
    head :unprocessable_entity
  end

  def destroy
    authorize @task
    @board_column = @task.board_column
    @task.soft_delete

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to project_board_path(@project), notice: t("tasks.destroyed") }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.expect(task: [ :title, :description, :priority, :board_column_id, label_ids: [] ])
  end
end
