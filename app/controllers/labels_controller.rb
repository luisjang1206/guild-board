# frozen_string_literal: true

class LabelsController < ApplicationController
  include ActivityLoggable

  before_action :set_project
  before_action :set_label, only: [ :edit, :update, :destroy ]

  def index
    authorize @project, :update?
    @labels = @project.labels.order(:name)
    @label = @project.labels.build
  end

  def create
    authorize @project, :update?
    @label = @project.labels.build(label_params)
    if @label.save
      log_activity(action: "label_created", metadata: { name: [ nil, @label.name ] })
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("labels-list",
            partial: "labels/label",
            locals: { label: @label, project: @project })
        end
        format.html { redirect_to project_labels_path(@project) }
      end
    else
      @labels = @project.labels.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project, :update?
  end

  def update
    authorize @project, :update?
    if @label.update(label_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("label_#{@label.id}",
            partial: "labels/label",
            locals: { label: @label, project: @project })
        end
        format.html { redirect_to project_labels_path(@project) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project, :update?
    @label.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("label_#{@label.id}") }
      format.html { redirect_to project_labels_path(@project) }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_label
    @label = @project.labels.find(params[:id])
  end

  def label_params
    params.expect(label: [ :name, :color ])
  end
end
