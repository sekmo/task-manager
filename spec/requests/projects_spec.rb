require "rails_helper"

describe "Projects API", type: :request do
  let(:json_content_headers) { {"Content-type" => "application/json"} }
  let(:invalid_id) { 999_999_999_999 }

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
        response_body_hash = body_from_json_response
        expect(response_body_hash.size).to eq(projects.size)
        response_body_hash.each_with_index do |hash, index|
          expect(hash).to eq(projects[index].as_json)
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
        response_body_hash = body_from_json_response
        expect(response_body_hash).to eq(project.as_json)
      end
    end

    context "when the record does not exist" do
      before :each do
        get api_project_path(invalid_id)
      end

      it "returns 404" do
        expect(response).to have_http_status(404)
      end

      it "returns a not found message" do
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("The project cannot be found.")
      end
    end
  end

  describe "POST /api/projects/" do
    context "with valid parameters" do
      let(:valid_parameters) { {project: {name: "Repaint the house"}} }

      it "returns 201" do
        post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        expect(response).to have_http_status(201)
      end

      it "creates a new project" do
        expect {
          post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        }.to change(Project, :count).by(1)
      end

      it "returns the project" do
        post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        response_body_hash = body_from_json_response
        project_hash = response_body_hash["project"]
        project_id = project_hash["id"]
        expect(project_hash).to eq(Project.find(project_id).as_json)
      end

      it "returns a successful message" do
        post api_projects_path, params: valid_parameters.to_json, headers: json_content_headers
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("Successfully created project.")
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
    let!(:project) { create(:project, name: "Build the bookshelf") }

    context "when the record exists" do
      it "returns 200" do
        delete api_project_path(project.id), headers: json_content_headers
        expect(response).to have_http_status(200)
      end

      it "deletes the project" do
        expect {
          delete api_project_path(project.id), headers: json_content_headers
        }.to change(Project, :count).by(-1)
      end
    end

    context "when the record does not exist" do
      it "returns 404" do
        delete api_project_path(invalid_id), headers: json_content_headers
        expect(response).to have_http_status(404)
      end

      it "does not delete any project" do
        expect {
          delete api_project_path(invalid_id), headers: json_content_headers
        }.not_to change(Project, :count)
      end
    end
  end

  describe "PUT /api/projects/:id" do
    let!(:project) { create(:project, name: "Build the bookshelf") }

    context "when the record exists, with valid parameters" do
      let(:valid_parameters) { {project: {name: "Build the super-bookshelf"}} }

      it "returns 200" do
        put api_project_path(project.id), headers: json_content_headers,
                                          params: valid_parameters.to_json
        expect(response).to have_http_status(200)
      end

      it "updates the project" do
        expect {
          put api_project_path(project.id), headers: json_content_headers,
                                            params: valid_parameters.to_json
        }.to change { project.reload.name }.from(project.name)
                                           .to(valid_parameters[:project][:name])
      end

      it "returns the project" do
        put api_project_path(project.id), headers: json_content_headers,
                                          params: valid_parameters.to_json
        response_body_hash = body_from_json_response
        project_hash = response_body_hash["project"]
        project_id = project_hash["id"]
        expect(project_hash).to eq(Project.find(project_id).as_json)
      end
    end

    context "when the record exists, with invalid parameters" do
      let(:invalid_parameters) { {project: {name: ""}} }

      it "returns 422" do
        put api_project_path(project.id), headers: json_content_headers,
                                          params: invalid_parameters.to_json
        expect(response).to have_http_status(422)
      end

      it "does not update the project" do
        expect {
          put api_project_path(project.id), headers: json_content_headers,
                                            params: invalid_parameters.to_json
        }.not_to change { project.reload.updated_at }
      end
    end

    context "when the record does not exist" do
      it "returns 404" do
        delete api_project_path(invalid_id), headers: json_content_headers
        expect(response).to have_http_status(404)
      end

      it "does not touch any project" do
        expect {
          delete api_project_path(invalid_id), headers: json_content_headers
        }.not_to change { Project.maximum(:updated_at) }
      end
    end
  end
end
