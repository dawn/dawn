require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  setup do
    @domain = domains(:one)
  end

  test "should error on index" do
    get :index
    assert_response :error
  end

  test "should error on create" do
    get :create
    assert_response :error
  end

  test "should show domain" do
    get :show, id: @domain
    assert_response :success
  end

  test "should not update domain" do
    patch :update, id: @domain, domain: {  }
    assert_response :error
  end

  test "should destroy domain" do
    assert_difference('Domain.count', -1) do
      delete :destroy, id: @domain
    end
  end
end
