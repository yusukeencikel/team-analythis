require "test_helper"

class BattingStatsOcrsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get batting_stats_ocrs_new_url
    assert_response :success
  end

  test "should get create" do
    get batting_stats_ocrs_create_url
    assert_response :success
  end
end
