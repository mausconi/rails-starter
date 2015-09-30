require 'test_helper'

#
# == Admin namespace
#
module Admin
  #
  # == StringBoxesController test
  #
  class StringBoxesControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup :initialize_test

    #
    # == Routes / Templates / Responses
    #
    test 'should get index page if logged in' do
      get :index
      assert_response :success
    end

    test 'should get show page if logged in' do
      get :show, id: @string_box
      assert_response :success
    end

    test 'should get edit page if logged in' do
      get :edit, id: @string_box
      assert_response :success
    end

    test 'should update category if logged in' do
      patch :update, id: @string_box, string_box: {}
      assert_redirected_to admin_string_box_path(@string_box)
    end

    test 'should not destroy string_box' do
      assert_no_difference 'StringBox.count' do
        delete :destroy, id: @string_box
      end
      assert_redirected_to admin_dashboard_path
    end

    #
    # == Crud actions
    #
    test 'should redirect to users/sign_in if not logged in' do
      sign_out @administrator
      assert_crud_actions(@string_box, new_user_session_path, model_name)
    end

    test 'should redirect to dashboard if subscriber' do
      sign_in @subscriber
      assert_crud_actions(@string_box, admin_dashboard_path, model_name)
    end

    #
    # == User roles
    #
    test 'should not save optional_module params if administrator' do
      patch :update, id: @string_box, string_box: { optional_module_id: @adult_module.id }
      assert_nil assigns(:string_box).optional_module_id
    end

    test 'should save optional_module params if super_administrator' do
      sign_in @super_administrator
      patch :update, id: @string_box, string_box: { optional_module_id: @adult_module.id }
      assert_equal @adult_module.id, assigns(:string_box).optional_module_id
    end

    #
    # == Abilities
    #
    test 'should test abilities for subscriber' do
      sign_in @subscriber
      ability = Ability.new(@subscriber)
      assert ability.cannot?(:create, StringBox.new), 'should not be able to create'
      assert ability.cannot?(:read, @string_box), 'should not be able to read'
      assert ability.cannot?(:update, @string_box), 'should not be able to update'
      assert ability.cannot?(:destroy, @string_box), 'should not be able to destroy'
    end

    test 'should test abilities for administrator' do
      ability = Ability.new(@administrator)
      assert ability.cannot?(:create, StringBox.new), 'should not be able to create'
      assert ability.can?(:read, @string_box), 'should be able to read'
      assert ability.can?(:update, @string_box), 'should be able to update'
      assert ability.cannot?(:destroy, @string_box), 'should not be able to destroy'
    end

    test 'should test abilities for super_administrator' do
      sign_in @super_administrator
      ability = Ability.new(@super_administrator)
      assert ability.can?(:create, StringBox.new), 'should be able to create'
      assert ability.can?(:read, @string_box), 'should be able to read'
      assert ability.can?(:update, @string_box), 'should be able to update'
      assert ability.can?(:destroy, @string_box), 'should be able to destroy'
    end

    #
    # == Optional Modules disabled
    #
    test 'should not be able to manage with newsletter disabled' do
      disable_optional_module @super_administrator, @newsletter_module, 'Newsletter' # in test_helper.rb
      sign_in @administrator
      ability = Ability.new(@administrator)
      assert ability.cannot?(:read, @string_box_newsletter), 'should not be able to read'
      assert ability.cannot?(:update, @string_box_newsletter), 'should not be able to update'
      assert ability.cannot?(:destroy, @string_box_newsletter), 'should not be able to destroy'
    end

    test 'should not be able to manage with adult disabled' do
      disable_optional_module @super_administrator, @adult_module, 'Adult' # in test_helper.rb
      sign_in @administrator
      ability = Ability.new(@administrator)
      assert ability.cannot?(:read, @string_box_adult), 'should not be able to read'
      assert ability.cannot?(:update, @string_box_adult), 'should not be able to update'
      assert ability.cannot?(:destroy, @string_box_adult), 'should not be able to destroy'
    end

    private

    def initialize_test
      @string_box = string_boxes(:error_404)
      @string_box_newsletter = string_boxes(:welcome_newsletter)
      @string_box_adult = string_boxes(:adult_not_validated_popup_content)
      @newsletter_module = optional_modules(:newsletter)
      @adult_module = optional_modules(:adult)

      @subscriber = users(:alice)
      @administrator = users(:bob)
      @super_administrator = users(:anthony)
      sign_in @administrator
    end
  end
end
