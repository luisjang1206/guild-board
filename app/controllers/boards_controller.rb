class BoardsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    authorize @project, :show?
    @board_columns = @project.board_columns
      .includes(tasks: [ :labels, :checklists, :comments ])
      .order(:position)

    @filters = {
      priority: params[:priority],
      label_id: params[:label_id],
      creator_type: params[:creator_type]
    }.compact_blank

    @labels = @project.labels.order(:name)
  end
end
