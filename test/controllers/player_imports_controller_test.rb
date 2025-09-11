require "test_helper"

class PlayerImportsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get player_imports_new_url
    assert_response :success
  end

  test "should get create" do
    get player_imports_create_url
    assert_response :success
  end
end
