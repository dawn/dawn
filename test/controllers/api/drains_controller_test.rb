require 'test_helper'

class DrainsControllerTest < ActionController::TestCase
  setup do
    @drain = drains(:one)
  end

  test "should error on index" do
    get :index
    assert_response :error
  end

  test "should error on create" do
    get :create
    assert_response :error
  end

  test "should show drain" do
    get :show, id: @drain
    assert_response :success
  end

  test "should not update drain" do
    patch :update, id: @drain, drain: {  }
    assert_response :error
  end

  test "should destroy drain" do
    assert_difference('Gear.count', -1) do
      delete :destroy, id: @drain
    end
  end
end
