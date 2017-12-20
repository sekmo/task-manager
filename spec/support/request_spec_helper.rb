module RequestSpecHelper
  def body_from_json_response
    JSON.parse(response.body)
  end
end
