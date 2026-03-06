# frozen_string_literal: true

class ChecklistsController < ApplicationController
  before_action :set_project
  before_action :set_task

  def create
    authorize @project, :update?
    @checklist = @task.checklists.build(checklist_params)
    if @checklist.save
      redirect_to project_task_path(@project, @task)
    else
      head :unprocessable_entity
    end
  end

  def update
    authorize @project, :update?
    @checklist = @task.checklists.find(params[:id])
    @checklist.update!(checklist_params)
    redirect_to project_task_path(@project, @task)
  end

  def destroy
    authorize @project, :update?
    @checklist = @task.checklists.find(params[:id])
    @checklist.destroy
    redirect_to project_task_path(@project, @task)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def checklist_params
    params.expect(checklist: [ :content, :completed ])
  end
end
