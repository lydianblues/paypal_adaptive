require 'test_helper'

class PreapprovalsControllerTest < ActionController::TestCase
  setup do
    @preapproval = preapprovals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:preapprovals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create preapproval" do
    assert_difference('Preapproval.count') do
      post :create, preapproval: @preapproval.attributes
    end

    assert_redirected_to preapproval_path(assigns(:preapproval))
  end

  test "should show preapproval" do
    get :show, id: @preapproval.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @preapproval.to_param
    assert_response :success
  end

  test "should update preapproval" do
    put :update, id: @preapproval.to_param, preapproval: @preapproval.attributes
    assert_redirected_to preapproval_path(assigns(:preapproval))
  end

  test "should destroy preapproval" do
    assert_difference('Preapproval.count', -1) do
      delete :destroy, id: @preapproval.to_param
    end

    assert_redirected_to preapprovals_path
  end
end
