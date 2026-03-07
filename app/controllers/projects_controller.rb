class ProjectsController < ApplicationController
  def index
    @pagy, @projects = pagy(
      policy_scope(Project)
        .includes(:labels, :tasks, board_columns: { tasks: :comments })
        .order(created_at: :desc),
      limit: 12
    )
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
    @board_columns = @project.board_columns.order(:position)
    @project_keys = @project.project_keys.order(created_at: :desc)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Current.user.projects.build(project_params)
    authorize @project

    if @project.save
      redirect_to @project, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @project = Project.find(params[:id])
    authorize @project
  end

  def update
    @project = Project.find(params[:id])
    authorize @project

    if @project.update(project_params)
      redirect_to @project, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    authorize @project
    @project.destroy
    redirect_to projects_path, notice: t(".destroyed")
  end

  private

  def project_params
    params.expect(project: [ :name, :description ])
  end
end
