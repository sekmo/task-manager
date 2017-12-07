require "rails_helper"

describe "Projects API", type: :request do
  describe "GET /api/projects/" do
    context "with no projects" do
      it "returns an empty collection" do
        get api_projects_path
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json.size).to eq(0)
      end
    end

    context "with 1 project" do
      let!(:project) { create(:project, name: "Build the bookshelf") }

      it "returns the project" do
        get api_projects_path
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json.size).to eq(1)
        expect(json[0]["name"]).to eq project.name
      end
    end

    context "with 20 projects" do
      let!(:projects) { create_list(:project, 20) }

      it "returns all the projects" do
        get api_projects_path
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json.size).to eq(projects.size)
      end
    end
  end

  describe "POST /api/projects/" do
    context "with valid parameters" do
      let(:valid_parameters) { {project: {name: "Repaint the house"}}.to_json }

      it "creates a new project" do
        headers = {"Content-type" => "application/json"}
        expect {
          post api_projects_path, params: valid_parameters,
                                  headers: headers
        }.to change(Project, :count).by(1)
        expect(response).to have_http_status(200)
      end
    end

    context "with invalid parameters" do
      let(:invalid_parameters) { {project: {name: ""}}.to_json }

      it "does not create a new project" do
        headers = {"Content-type" => "application/json"}
        expect {
          post api_projects_path, params: invalid_parameters,
                                  headers: headers
        }.not_to change(Project, :count)
        expect(response).to have_http_status(422)
      end
    end
  end
end
