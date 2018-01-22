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
        message: "The task cannot be created.",
        errors: task.errors
      }.to_json
    end
  end

  def update
    if @task.update(task_params)
      render status: 200, json: {
        message: "Successfully updated task.",
        task: @task
      }.to_json
    else
      render status: 422, json: {
        message: "The task can't be updated."
      }.to_json
    end
  end

  def destroy
    @task.destroy
    render status: 200, json: {
      message: "The task has been successfully deleted."
    }.to_json
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
