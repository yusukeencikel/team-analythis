require "test_helper"

class OurTeamsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get our_teams_show_url
    assert_response :success
  end

  test "should get edit" do
    get our_teams_edit_url
    assert_response :success
  end

  test "should get update" do
    get our_teams_update_url
    assert_response :success
  end
end
