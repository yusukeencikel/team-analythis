require "test_helper"

class TeamAnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get team_analytics_show_url
    assert_response :success
  end
end
