require 'test_helper'

class KeysControllerTest < ActionController::TestCase
  setup do
    @key = keys(:one)
  end

  test "should get all user keys" do
    post :create, key: "--insert-key-here--"
    assert_response :success
  end

  test "should get all user keys" do
    get :index
    assert_response :success
  end

  test "should show key" do
    get :show, id: @key
    assert_response :success
  end

  test "should destroy key" do
    assert_difference('Key.count', -1) do
      delete :destroy, id: @key
    end
  end
end
