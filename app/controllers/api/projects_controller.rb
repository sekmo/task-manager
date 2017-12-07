class Api::ProjectsController < ApplicationController
  def index
    render json: Project.all
  end

  def show
    render json: Project.find(params[:id])
  end

  def create
    project = Project.new(project_params)
    if project.save
      render status: 200, json: {
        message: "Successfully created project.",
        project: project
      }.to_json
    else
      render status: 422, json: {
        errors: project.errors
      }.to_json
    end
  end

  def destroy
    project = Project.find(params[:id])
    project.destroy
    render status: 200, json: {
      message: "Successfully deleted project."
    }.to_json
  end

  def update
    project = Project.find(params[:id])
    if project.update(project_params)
      render status: 200, json: {
        message: "Successfully updated project.",
        project: project
      }.to_json
    else
      render status: 422, json: {
        message: "The project can't be updated"
      }.to_json
    end
  end

  private

  def project_params
    params.require("project").permit("name")
  end
end
