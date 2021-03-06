# frozen_string_literal: true
require 'test_helper'

#
# == Admin namespace
#
module Admin
  #
  # == BlogSettingsController test
  #
  class BlogSettingsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup :initialize_test

    #
    # == Routes / Templates / Responses
    #
    test 'should get index page if logged in' do
      get :index
      assert_response 301
      assert_redirected_to admin_blog_setting_path(@blog_settings)
    end

    test 'should get show page if logged in' do
      get :show, params: { id: @blog_settings }
      assert_response :success
    end

    test 'should get edit page if logged in' do
      get :edit, params: { id: @blog_settings }
      assert_response :success
    end

    test 'should update blog_setting if logged in' do
      patch :update, params: { id: @blog_settings, blog_setting: {} }
      assert_redirected_to admin_blog_setting_path(@blog_settings)
    end

    test 'should not destroy blog_setting' do
      assert_no_difference 'BlogSetting.count' do
        delete :destroy, params: { id: @blog_settings }
      end
    end

    #
    # == Allowed params
    #
    test 'should save show_last_comments params if module is enabled' do
      patch :update, params: { id: @blog_settings, blog_setting: { show_last_comments: true } }
      assert assigns(:blog_setting).show_last_comments?
    end

    test 'should not save show_last_comments params if module is disabled' do
      disable_optional_module @super_administrator, @comment_module, 'Comment' # in test_helper.rb
      sign_in @administrator
      patch :update, params: { id: @blog_settings, blog_setting: { show_last_comments: true } }
      assert_not assigns(:blog_setting).show_last_comments?
    end

    #
    # == Crud actions
    #
    test 'should redirect to users/sign_in if not logged in' do
      sign_out @administrator
      assert_crud_actions(@blog_settings, new_user_session_path, model_name)
    end

    test 'should redirect to dashboard if subscriber' do
      sign_in @subscriber
      assert_crud_actions(@blog_settings, admin_dashboard_path, model_name)
    end

    #
    # == Module disabled
    #
    test 'should not access page if blog module is disabled' do
      disable_optional_module @super_administrator, @blog_module, 'Blog' # in test_helper.rb
      sign_in @super_administrator
      assert_crud_actions(@blog_settings, admin_dashboard_path, model_name)
      sign_in @administrator
      assert_crud_actions(@blog_settings, admin_dashboard_path, model_name)
      sign_in @subscriber
      assert_crud_actions(@blog_settings, admin_dashboard_path, model_name)
    end

    #
    # == Maintenance
    #
    test 'should not render maintenance even if enabled and SA' do
      sign_in @super_administrator
      assert_no_maintenance_backend(:show, @blog_settings)
    end

    test 'should not render maintenance even if enabled and Admin' do
      sign_in @administrator
      assert_no_maintenance_backend(:show, @blog_settings)
    end

    test 'should render maintenance if enabled and subscriber' do
      sign_in @subscriber
      assert_maintenance_backend
      assert_redirected_to admin_dashboard_path
    end

    test 'should redirect to login if maintenance and not connected' do
      sign_out @administrator
      assert_maintenance_backend
      assert_redirected_to new_user_session_path
    end

    #
    # == Abilities
    #
    test 'should test abilities for subscriber' do
      sign_in @subscriber
      ability = Ability.new(@subscriber)
      assert ability.cannot?(:create, BlogSetting.new), 'should not be able to create'
      assert ability.cannot?(:read, @blog_settings), 'should not be able to read'
      assert ability.cannot?(:update, @blog_settings), 'should not be able to update'
      assert ability.cannot?(:destroy, @blog_settings), 'should not be able to destroy'
    end

    test 'should test abilities for administrator' do
      ability = Ability.new(@administrator)
      assert ability.cannot?(:create, BlogSetting.new), 'should not be able to create'
      assert ability.can?(:read, @blog_settings), 'should be able to read'
      assert ability.can?(:update, @blog_settings), 'should be able to update'
      assert ability.cannot?(:destroy, @blog_settings), 'should not be able to destroy'
    end

    test 'should test abilities for super_administrator' do
      sign_in @super_administrator
      ability = Ability.new(@super_administrator)
      assert ability.cannot?(:create, BlogSetting.new), 'should not be able to create'
      assert ability.can?(:read, @blog_settings), 'should be able to read'
      assert ability.can?(:update, @blog_settings), 'should be able to update'
      assert ability.cannot?(:destroy, @blog_settings), 'should not be able to destroy'
    end

    private

    def initialize_test
      @setting = settings(:one)
      @blog_settings = blog_settings(:one)
      @blog_module = optional_modules(:blog)
      @comment_module = optional_modules(:comment)

      @subscriber = users(:alice)
      @administrator = users(:bob)
      @super_administrator = users(:anthony)
      sign_in @administrator
    end
  end
end
