require 'test_helper'

class RevenueModelsControllerTest < ActionController::TestCase
  setup do
    @revenue_model = revenue_models(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:revenue_models)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create revenue_model" do
    assert_difference('RevenueModel.count') do
      post :create, revenue_model: { company: @revenue_model.company, ent_id: @revenue_model.ent_id, is_verified: @revenue_model.is_verified, revenue_mill: @revenue_model.revenue_mill, source: @revenue_model.source, updated_at: @revenue_model.updated_at, updated_by: @revenue_model.updated_by }
    end

    assert_redirected_to revenue_model_path(assigns(:revenue_model))
  end

  test "should show revenue_model" do
    get :show, id: @revenue_model
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @revenue_model
    assert_response :success
  end

  test "should update revenue_model" do
    put :update, id: @revenue_model, revenue_model: { company: @revenue_model.company, ent_id: @revenue_model.ent_id, is_verified: @revenue_model.is_verified, revenue_mill: @revenue_model.revenue_mill, source: @revenue_model.source, updated_at: @revenue_model.updated_at, updated_by: @revenue_model.updated_by }
    assert_redirected_to revenue_model_path(assigns(:revenue_model))
  end

  test "should destroy revenue_model" do
    assert_difference('RevenueModel.count', -1) do
      delete :destroy, id: @revenue_model
    end

    assert_redirected_to revenue_models_path
  end
end
