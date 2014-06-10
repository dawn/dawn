require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  setup do
    @app = apps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create app" do
    assert_difference('User.count') do
      post :create, app: {  }
    end
  end

  test "should show app" do
    get :show, id: @app
    assert_response :success
  end

  test "should update app" do
    patch :update, id: @app, app: { name: "BrickyWorx" }
    assert_response :success
  end

  test "should get app env" do
    get :get_env, id: @app
  end

  test "should update app env" do
    post :update_env, id: @app, env: { "HOST_NAME"=> "cookies.com" }
  end

  test "should get app formation" do
    get :formation, id: @app
  end

  test "should update app formation" do
    post :scale, id: @app, formation: { web: 2 }
  end

  test "should run command in app container" do
    post :run, id: @app, command: "time"
  end

  test "should create a new gear on app" do
    post :create_gear, id: @app, type: "web"
  end

  test "should create a new drain on app" do
    post :create_drain, id: @app, url: "http://logs.brickworx.io"
  end

  test "should create a new domain on app" do
    post :create_domain, id: @app, url: "http://brickworx.io"
  end

  test "should get app gears" do
    get :gears, id: @app
  end

  test "should get app domains" do
    get :domains, id: @app
  end

  test "should get app drains" do
    get :drains, id: @app
  end

  test "should restart app gears" do
    post :gears_restart, id: @app
  end

  test "should destroy app" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @app
    end
  end

end
