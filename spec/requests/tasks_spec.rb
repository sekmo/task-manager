require "rails_helper"

describe "Tasks API", type: :request do
  let(:json_content_headers) { {"Content-type" => "application/json"} }
  let(:project) { create(:project) }
  let(:valid_task_parameters) { {task: attributes_for(:task)}.to_json }

  describe "POST /api/projects/:project_id/tasks" do
    context "with valid project_id, task parameters" do
      def send_valid_post_request
        post api_project_tasks_path(project.id), params: valid_task_parameters,
                                                 headers: json_content_headers
      end

      it "returns 200" do
        send_valid_post_request
        expect(response).to have_http_status(200)
      end

      it "creates a new task" do
        expect {
          send_valid_post_request
        }.to change(Task, :count).by(1)
      end

      it "returns the task" do
        send_valid_post_request
        parsed_response = JSON.parse(response.body)
        returned_task = parsed_response["task"]
        persisted_task = Task.find(returned_task["id"])
        expect(returned_task).to eq(persisted_task.as_json)
      end

      it "returns a successful message" do
        send_valid_post_request
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq("Successfully created task.")
      end
    end

    context "with an invalid project_id" do
      def send_post_request_with_invalid_project_id
        post api_project_tasks_path(99999), params: valid_task_parameters,
                                            headers: json_content_headers
      end

      it "returns 404" do
        send_post_request_with_invalid_project_id
        expect(response).to have_http_status(404)
      end

      it "does not create a new task" do
        expect {
          send_post_request_with_invalid_project_id
        }.not_to change(Task, :count)
      end

      it "returns a not found message" do
        send_post_request_with_invalid_project_id
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq("The project cannot be found.")
      end
    end
  end
end
