require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "GET /health returns ok when database is connected" do
    get "/health"
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
  end
end
