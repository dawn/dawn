require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    # login or something
  end

  test "should get current_user" do
    get :index
    assert_response :success
  end

  test "should update current_user" do
    patch :update, username: "ThatGuy"
  end

end
