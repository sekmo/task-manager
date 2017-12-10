require "rails_helper"

describe "Projects API", type: :request do
  let(:json_content_headers) { {"Content-type" => "application/json"} }

  describe "GET /api/projects/" do
    context "with no projects" do
      before :each do
        get api_projects_path
      end

      it "returns 200" do
        expect(response).to have_http_status(200)
      end

      it "returns an empty collection" do
        expect(response.body).to eq("[]")
      end
    end

    context "with 20 projects" do
      let!(:projects) { create_list(:project, 20) }

      before :each do
        get api_projects_path
      end

      it "returns 200" do
        expect(response).to have_http_status(200)
      end

      it "returns all the projects" do
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(projects.size)
        json_response.each_with_index do |json_object, index|
          expect(json_object["name"]).to eq(projects[index].name)
        end
      end
    end
  end

  describe "GET /api/projects/:id" do
    let(:project) { create(:project, name: "Build the bookshelf") }

    context "when the record exists" do
      before :each do
        get api_project_path(project.id)
      end

      it "returns 200" do
        expect(response).to have_http_status(200)
      end

      it "returns the project" do
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq(project.name)
      end
    end

    context "when the record does not exist" do
      before :each do
        get api_project_path(99999)
      end

      it "returns 404" do
        expect(response).to have_http_status(404)
      end

      it "returns a not found message" do
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("The project cannot be found.")
      end
    end
  end

  describe "POST /api/projects/" do
    context "with valid parameters" do
      project_name = "Repaint the house"
      let(:valid_parameters) { {project: {name: project_name}} }

      it "returns 200" do
        post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        expect(response).to have_http_status(200)
      end

      it "creates a new project" do
        expect {
          post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        }.to change(Project, :count).by(1)
      end

      it "returns the project" do
        post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        json_response = JSON.parse(response.body)
        project_json = json_response["project"]
        project_id = project_json["id"]
        expect(project_json).to eq(Project.find(project_id).as_json)
      end

      it "returns a successful message" do
        post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Successfully created project.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_parameters) { {project: {name: ""}} }

      it "returns 422" do
        post api_projects_path, params: invalid_parameters.to_json, headers: json_content_headers
        expect(response).to have_http_status(422)
      end

      it "does not create a new project" do
        expect {
          post api_projects_path, params: invalid_parameters.to_json, headers: json_content_headers
        }.not_to change(Project, :count)
      end
    end
  end

  describe "DELETE /api/projects/:id" do
    before :each do
      @project = create(:project, name: "Build the bookshelf")
    end
    let(:headers) { {"Content-type" => "application/json"} }

    context "when the record exists" do
      it "returns 200" do
        delete api_project_path(@project.id), headers: json_content_headers
        expect(response).to have_http_status(200)
      end

      it "deletes the project" do
        expect {
          delete api_project_path(@project.id), headers: json_content_headers
        }.to change(Project, :count).by(-1)
      end
    end

    context "when the record does not exist" do
      it "returns 404" do
        delete api_project_path(99999), headers: json_content_headers
        expect(response).to have_http_status(404)
      end

      it "does not delete any project" do
        expect {
          delete api_project_path(99999), headers: json_content_headers
        }.not_to change(Project, :count)
      end
    end
  end
end
