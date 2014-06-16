require 'test_helper'

class GearsControllerTest < ActionController::TestCase
  setup do
    @gear = gears(:one)
  end

  test "should error on index" do
    get :index
    assert_response :error
  end

  test "should error on create" do
    get :create
    assert_response :error
  end

  test "should show gear" do
    get :show, id: @gear
    assert_response :success
  end

  test "should not update gear" do
    patch :update, id: @gear, gear: {  }
    assert_response :error
  end

  test "should destroy gear" do
    assert_difference('Gear.count', -1) do
      delete :destroy, id: @gear
    end
  end
end
