# frozen_string_literal: true
require 'test_helper'

#
# == Admin namespace
#
module Admin
  #
  # == EventsController test
  #
  class EventsControllerTest < ActionController::TestCase
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
      get :show, id: @event
      assert_response :success
    end

    test 'should get edit page if logged in' do
      get :edit, id: @event
      assert_response :success
    end

    test 'should update event if logged in' do
      patch :update, id: @event, event: { title: 'event edit', content: 'content edit' }
      assert_redirected_to admin_event_path(assigns(:event))
      assert flash[:notice].blank?
    end

    #
    # == Batch actions
    #
    test 'should return correct value for toggle_online batch action' do
      post :batch_action, batch_action: 'toggle_online', collection_selection: [@event.id]
      [@event].each(&:reload)
      assert_not @event.online?
    end

    test 'should redirect to back and have correct flash notice for toggle_online batch action' do
      post :batch_action, batch_action: 'toggle_online', collection_selection: [@event.id]
      assert_redirected_to admin_events_path
      assert_equal I18n.t('active_admin.batch_actions.flash'), flash[:notice]
    end

    test 'should return correct value for toggle_show_calendar batch action' do
      post :batch_action, batch_action: 'toggle_show_calendar', collection_selection: [@event.id]
      [@event].each(&:reload)
      assert @event.show_calendar?
    end

    test 'should redirect to back and have correct flash notice for toggle_show_calendar batch action' do
      post :batch_action, batch_action: 'toggle_show_calendar', collection_selection: [@event.id]
      assert_redirected_to admin_events_path
      assert_equal I18n.t('active_admin.batch_actions.flash'), flash[:notice]
    end

    test 'should redirect to back and have correct flash notice for reset_cache batch action' do
      post :batch_action, batch_action: 'reset_cache', collection_selection: [@event.id]
      assert_redirected_to admin_events_path
      assert_equal I18n.t('active_admin.batch_actions.reset_cache'), flash[:notice]
    end

    #
    # == Flash content
    #
    test 'should return empty flash notice if no update' do
      patch :update, id: @event, event: {}
      assert flash[:notice].blank?
    end

    test 'should return correct flash content after updating a video' do
      video = fixture_file_upload 'videos/test.mp4', 'video/mp4'
      patch :update, id: @event, event: { video_uploads_attributes: [{ video_file: video }] }
      assert_equal [I18n.t('video_upload.flash.upload_in_progress')], flash[:notice]
    end

    #
    # == Destroy
    #
    test 'should destroy event' do
      assert_difference ['Event.count', 'Link.count'], -1 do
        delete :destroy, id: @event
      end
      assert_redirected_to admin_events_path
    end

    #
    # == Maintenance
    #
    test 'should not render maintenance even if enabled and SA' do
      sign_in @super_administrator
      assert_no_maintenance_backend
    end

    test 'should not render maintenance even if enabled and Admin' do
      sign_in @administrator
      assert_no_maintenance_backend
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
      assert ability.cannot?(:create, Event.new), 'should not be able to create'
      assert ability.cannot?(:read, @event), 'should not be able to read'
      assert ability.cannot?(:update, @event), 'should not be able to update'
      assert ability.cannot?(:destroy, @event), 'should not be able to destroy'

      assert ability.cannot?(:toggle_online, @event), 'should not be able to toggle_online'
      assert ability.cannot?(:toggle_show_calendar, @event), 'should not be able to toggle_show_calendar'
      assert ability.cannot?(:reset_cache, @event), 'should not be able to reset_cache'
    end

    test 'should test abilities for administrator' do
      ability = Ability.new(@administrator)
      assert ability.can?(:create, Event.new), 'should be able to create'
      assert ability.can?(:read, @event), 'should be able to read'
      assert ability.can?(:update, @event), 'should be able to update'
      assert ability.can?(:destroy, @event), 'should be able to destroy'

      assert ability.can?(:toggle_online, @event), 'should be able to toggle_online'
      assert ability.can?(:toggle_show_calendar, @event), 'should be able to toggle_show_calendar'
      assert ability.can?(:reset_cache, @event), 'should be able to reset_cache'
    end

    test 'should test abilities for super_administrator' do
      sign_in @super_administrator
      ability = Ability.new(@super_administrator)
      assert ability.can?(:create, Event.new), 'should be able to create'
      assert ability.can?(:read, @event), 'should be able to read'
      assert ability.can?(:update, @event), 'should be able to update'
      assert ability.can?(:destroy, @event), 'should be able to destroy'

      assert ability.can?(:toggle_online, @event), 'should be able to toggle_online'
      assert ability.can?(:toggle_show_calendar, @event), 'should be able to toggle_show_calendar'
      assert ability.can?(:reset_cache, @event), 'should be able to reset_cache'
    end

    #
    # == Crud actions
    #
    test 'should redirect to users/sign_in if not logged in' do
      sign_out @administrator
      assert_crud_actions(@event, new_user_session_path, model_name)
    end

    test 'should redirect to dashboard if subscriber' do
      sign_in @subscriber
      assert_crud_actions(@event, admin_dashboard_path, model_name)
    end

    #
    # == Validation rules
    #
    test 'should save event if link is correct' do
      assert_difference ['Event.count'] do
        post :create, event: { url: 'http://google.com' }
      end
      assert assigns(:event).valid?
    end

    test 'should not save event if link is not correct' do
      assert_no_difference ['Event.count'] do
        post :create, event: { link_attributes: { url: 'fake.url' } }
      end
      assert_not assigns(:event).valid?
    end

    test 'should save event if dates are corrects' do
      assert_difference ['Event.count'] do
        post :create, event: { start_date: '2015-07-19 09:00:00', end_date: '2015-07-22 09:00:00' }
      end
      assert assigns(:event).valid?
    end

    test 'should save event if dates are equals but hours corrects' do
      assert_difference ['Event.count'] do
        post :create, event: { start_date: '2015-07-19 09:00:00', end_date: '2015-07-19 10:00:00' }
      end
      assert assigns(:event).valid?
    end

    test 'should not save event if dates are not corrects' do
      assert_no_difference ['Event.count'] do
        post :create, event: { start_date: '2015-07-22 09:00:00', end_date: '2015-07-19 09:00:00' }
      end
      assert_not assigns(:event).valid?
    end

    #
    # == Module disabled
    #
    test 'should not access page if event module is disabled' do
      disable_optional_module @super_administrator, @event_module, 'Event' # in test_helper.rb
      sign_in @super_administrator
      assert_crud_actions(@event, admin_dashboard_path, model_name)
      sign_in @administrator
      assert_crud_actions(@event, admin_dashboard_path, model_name)
      sign_in @subscriber
      assert_crud_actions(@event, admin_dashboard_path, model_name)
    end

    #
    # == Calendar module disabled
    #
    test 'should not create calendar if calendar module is disabled' do
      disable_optional_module @super_administrator, @calendar_module, 'Calendar' # in test_helper.rb
      sign_in @administrator
      post :create, event: { show_calendar: true }
      assert_not assigns(:event).show_calendar
    end

    test 'should create calendar if calendar module is enabled' do
      post :create, event: { show_calendar: true }
      assert assigns(:event).show_calendar
    end

    test 'should not update calendar if calendar module is disabled' do
      disable_optional_module @super_administrator, @calendar_module, 'Calendar' # in test_helper.rb
      sign_in @administrator
      patch :update, id: @event, event: { show_calendar: true }
      assert_not assigns(:event).show_calendar
    end

    test 'should update calendar if calendar module is enabled' do
      patch :update, id: @event, event: { show_calendar: true }
      assert assigns(:event).show_calendar
    end

    private

    def initialize_test
      @setting = settings(:one)
      @request.env['HTTP_REFERER'] = admin_events_path
      @event = events(:event_online)
      @event_not_validate = events(:event_offline)
      @event_module = optional_modules(:event)
      @calendar_module = optional_modules(:calendar)

      @subscriber = users(:alice)
      @administrator = users(:bob)
      @super_administrator = users(:anthony)
      sign_in @administrator
    end
  end
end
