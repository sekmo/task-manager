class Api::TasksController < ApplicationController
  before_action :find_project
  before_action :find_task, only: [:destroy, :update]

  def create
    task = @project.tasks.build(task_params)
    if task.save
      render status: 201, json: {
        message: "Successfully created task.",
        project: @project,
        task: task
      }.to_json
    else
      render status: 422, json: {
        errors: task.errors
      }.to_json
    end
  end

  def update
  end

  def destroy
  end

  private

  def task_params
    params.require("task").permit("title")
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: {
      message: "The project cannot be found."
    }.to_json
  end

  def find_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: {
      message: "The task cannot be found."
    }.to_json
  end
end
