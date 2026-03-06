class ProjectKeysController < ApplicationController
  before_action :set_project
  before_action :set_project_key, only: [ :destroy, :toggle_active, :regenerate ]

  def create
    authorize ProjectKey.new(project: @project)
    record, raw_key = ProjectKey.generate_for(@project, name: key_params[:name])
    redirect_to @project, flash: { project_key: raw_key, project_key_prefix: record.key_prefix }, notice: t(".created")
  end

  def destroy
    authorize @project_key
    @project_key.destroy
    redirect_to @project, notice: t(".destroyed")
  end

  def toggle_active
    authorize @project_key
    @project_key.update!(active: !@project_key.active)
    redirect_to @project, notice: t(".toggled")
  end

  def regenerate
    authorize @project_key
    @project_key.update!(active: false)
    new_key, raw_key = ProjectKey.generate_for(@project, name: "#{@project_key.name} (regenerated)")
    redirect_to @project, flash: { project_key: raw_key, project_key_prefix: new_key.key_prefix }, notice: t(".regenerated")
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_project_key
    @project_key = @project.project_keys.find(params[:id])
  end

  def key_params
    params.expect(project_key: [ :name ])
  end
end
