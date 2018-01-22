require "rails_helper"

describe "Tasks API", type: :request do
  let(:json_content_headers) { {"Content-type" => "application/json"} }
  let!(:project) { create(:project) }
  let!(:task) { create(:task) }
  let(:valid_task_parameters) { {task: attributes_for(:task)} }
  let(:invalid_task_parameters) { {task: attributes_for(:task, :invalid)} }
  let(:invalid_id) { 999_999_999_999 }

  describe "DELETE /api/projects/:project_id/tasks/:id" do
    context "with a valid project id, task id" do
      def send_valid_delete_request
        delete api_project_task_path(project.id, task.id)
      end

      it "returns 200" do
        send_valid_delete_request
        expect(response).to have_http_status(200)
      end

      it "deletes the task" do
        expect {
          send_valid_delete_request
        }.to change(Task, :count).by(-1)
      end

      it "returns a successful message" do
        send_valid_delete_request
        response_body_hash = body_from_json_response
        returned_message = response_body_hash["message"]
        expect(returned_message).to eq("The task has been successfully deleted.")
      end
    end

    context "with an invalid task id" do
      it "returns 404" do
        delete api_project_task_path(project.id, invalid_id)
        expect(response).to have_http_status(404)
      end

      it "does not delete any task" do
        expect {
          delete api_project_task_path(project.id, invalid_id)
        }.not_to change(Task, :count)
      end
    end

    context "with an invalid project id" do
      it "returns 404" do
        delete api_project_task_path(invalid_id, task.id)
        expect(response).to have_http_status(404)
      end

      it "does not delete any task" do
        expect {
          delete api_project_task_path(invalid_id, task.id)
        }.not_to change(Task, :count)
      end
    end
  end

  describe "POST /api/projects/:project_id/tasks" do
    context "with valid project_id, task parameters" do
      def send_valid_post_request
        post api_project_tasks_path(project.id), params: valid_task_parameters.to_json,
                                                 headers: json_content_headers
      end

      it "returns 201" do
        send_valid_post_request
        expect(response).to have_http_status(201)
      end

      it "creates a new task" do
        expect {
          send_valid_post_request
        }.to change(Task, :count).by(1)
      end

      it "returns the task" do
        send_valid_post_request
        response_body_hash = body_from_json_response
        returned_task = response_body_hash["task"]
        persisted_task = Task.find(returned_task["id"])
        expect(returned_task).to eq(persisted_task.as_json)
      end

      it "returns the project" do
        send_valid_post_request
        response_body_hash = body_from_json_response
        returned_project = response_body_hash["project"]
        expect(returned_project).to eq(project.as_json)
      end

      it "returns a successful message" do
        send_valid_post_request
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("Successfully created task.")
      end
    end

    context "with an invalid project_id" do
      def send_post_request_with_invalid_project_id
        post api_project_tasks_path(invalid_id), params: valid_task_parameters.to_json,
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
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("The project cannot be found.")
      end
    end

    context "with invalid task parameters" do
      def send_post_request_with_invalid_task_params
        post api_project_tasks_path(project.id), params: invalid_task_parameters.to_json,
                                                 headers: json_content_headers
      end

      it "returns 422" do
        send_post_request_with_invalid_task_params
        expect(response).to have_http_status(422)
      end

      it "does not create a new task" do
        expect {
          send_post_request_with_invalid_task_params
        }.not_to change(Task, :count)
      end

      it "returns an error message" do
        send_post_request_with_invalid_task_params
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("The task cannot be created.")
      end
    end
  end

  describe "PUT /api/projects/:project_id/tasks/:id" do
    let(:new_task_title) { "updated_task_title" }
    let(:updated_task_parameters) { {task: attributes_for(:task, title: new_task_title)} }

    context "with valid project_id, task id, task parameters" do
      def send_valid_put_request
        put api_project_task_path(project.id, task.id), headers: json_content_headers,
                                                        params: updated_task_parameters.to_json
      end

      it "returns 200" do
        send_valid_put_request
        expect(response).to have_http_status(200)
      end

      it "updates the task" do
        expect { send_valid_put_request
        }.to change { task.reload.title }.from(task.title).to(new_task_title)
      end

      it "returns the task" do
        send_valid_put_request
        response_body_hash = body_from_json_response
        task_hash = response_body_hash["task"]
        expect(task_hash).to eq(task.reload.as_json)
      end
    end

    context "with invalid parameters" do
      def send_put_request_with_invalid_parameters
        put api_project_task_path(project.id, task.id), headers: json_content_headers,
                                                        params: invalid_task_parameters.to_json
      end

      it "returns 422" do
        send_put_request_with_invalid_parameters
        expect(response).to have_http_status(422)
      end

      it "doesn't update the task" do
        expect { send_put_request_with_invalid_parameters }.not_to change { task.reload.updated_at }
      end
    end

    context "with invalid project_id" do
      def send_put_request_with_invalid_project_id
        put api_project_task_path(invalid_id, task.id), headers: json_content_headers,
                                                        params: updated_task_parameters.to_json
      end

      it "returns 404" do
        send_put_request_with_invalid_project_id
        expect(response).to have_http_status(404)
      end

      it "doesn't update the task" do
        expect { send_put_request_with_invalid_project_id }.not_to change { task.reload.updated_at }
      end

      it "returns an error message" do
        send_put_request_with_invalid_project_id
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("The project cannot be found.")
      end
    end

    context "with invalid task_id" do
      def send_put_request_with_invalid_task_id
        put api_project_task_path(project.id, invalid_id), headers: json_content_headers,
                                                           params: updated_task_parameters.to_json
      end

      it "returns 404" do
        send_put_request_with_invalid_task_id
        expect(response).to have_http_status(404)
      end

      it "doesn't update the task" do
        expect { send_put_request_with_invalid_task_id }.not_to change { task.reload.updated_at }
      end

      it "returns an error message" do
        send_put_request_with_invalid_task_id
        response_body_hash = body_from_json_response
        expect(response_body_hash["message"]).to eq("The task cannot be found.")
      end
    end
  end
end
