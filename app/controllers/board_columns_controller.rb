class BoardColumnsController < ApplicationController
  before_action :set_project
  before_action :set_column, only: [ :update, :destroy, :move ]

  def create
    authorize @project, :update?
    @column = @project.board_columns.build(column_params)
    if @column.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.before("add-column-btn", partial: "board_columns/column", locals: { column: @column, project: @project, tasks: [] }) }
        format.html { redirect_to project_board_path(@project) }
      end
    else
      redirect_to project_board_path(@project), alert: @column.errors.full_messages.join(", ")
    end
  end

  def update
    authorize @project, :update?
    if @column.update(column_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    authorize @project, :update?
    if @column.tasks.active.any?
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash", partial: "shared/flash_message", locals: { message: t("board_columns.cannot_delete_with_tasks"), type: :alert }) }
        format.html { redirect_to project_board_path(@project), alert: t("board_columns.cannot_delete_with_tasks") }
      end
    else
      @column.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("board_column_#{@column.id}") }
        format.html { redirect_to project_board_path(@project) }
      end
    end
  end

  def move
    authorize @project, :update?
    @column.move_to_position(params[:position].to_i)
    head :ok
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_column
    @column = @project.board_columns.find(params[:id])
  end

  def column_params
    params.expect(board_column: [ :name ])
  end
end
