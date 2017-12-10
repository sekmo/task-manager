require "rails_helper"

describe "Projects API", type: :request do
  describe "GET /api/projects/" do
    context "with no projects" do
      it "returns an empty collection" do
        get api_projects_path
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(0)
      end
    end

    context "with 20 projects" do
      let!(:projects) { create_list(:project, 20) }

      it "returns all the projects" do
        get api_projects_path
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(projects.size)
      end
    end
  end

  describe "GET /api/projects/:id" do
    let(:project) { create(:project, name: "Build the bookshelf") }
    let(:project_id) { project.id }

    context "when the record exists" do
      it "returns 200" do
        get api_project_path(project_id)
        expect(response).to have_http_status(200)
      end

      it "returns the project" do
        get api_project_path(project_id)
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq(project.name)
      end
    end

    context "when the record does not exist" do
      it "returns 404" do
        get api_project_path(99999)
        expect(response).to have_http_status(404)
      end

      it "returns a not found message" do
        get api_project_path(99999)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("The project cannot be found")
      end
    end
  end

  describe "POST /api/projects/" do
    let(:headers) { {"Content-type" => "application/json"} }

    context "with valid parameters" do
      let(:valid_parameters) { {project: {name: "Repaint the house"}} }

      it "creates a new project" do
        expect {
          post api_projects_path, params: valid_parameters.to_json,
                                  headers: headers
        }.to change(Project, :count).by(1)
        expect(response).to have_http_status(200)
      end
    end

    context "with invalid parameters" do
      let(:invalid_parameters) { {project: {name: ""}} }

      it "does not create a new project" do
        expect {
          post api_projects_path, params: invalid_parameters.to_json,
                                  headers: headers
        }.not_to change(Project, :count)
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /api/projects/:id" do
    let(:headers) { {"Content-type" => "application/json"} }

    context "with valid parameters" do
      let(:valid_parameters) { {project: {name: "Repaint the house"}} }

      it "creates a new project" do
        expect {
          post api_projects_path, params: valid_parameters.to_json,
                                  headers: headers
        }.to change(Project, :count).by(1)
        expect(response).to have_http_status(200)
      end
    end

    context "with invalid parameters" do
      let(:invalid_parameters) { {project: {name: ""}} }

      it "does not create a new project" do
        expect {
          post api_projects_path, params: invalid_parameters.to_json,
                                  headers: headers
        }.not_to change(Project, :count)
        expect(response).to have_http_status(422)
      end
    end
  end
end
