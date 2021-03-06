# frozen_string_literal: true
require 'test_helper'

#
# == Core namespace
#
module Core
  #
  # == MenuHelper Test
  #
  class MenuHelperTest < ActionView::TestCase
    setup :initialize_test

    #
    # == Active menu element
    #
    test 'should return active class for home' do
      assert active_class?('homes', 'index')
    end

    test 'should not return active class if is show for home' do
      assert_not active_class?('homes', 'show')
    end

    test 'should return active class if is false for home' do
      assert active_class?('homes')
    end

    test 'should not return active class for contact' do
      assert_not active_class?('contacts', 'new')
    end

    test 'should not return active class if is false for contact' do
      assert_not active_class?('contacts')
    end

    test 'should return active class for blog when blog_categories' do
      params[:controller] = 'blog_categories'
      params[:action] = 'show'
      assert active_class?('blogs')
    end

    #
    # == Class name
    #
    test 'should return even class for menu' do
      assert_equal 'even', even_or_odd_menu_item([1, 2, 3, 4])
    end

    test 'should return odd class for menu' do
      assert_equal 'odd', even_or_odd_menu_item([1, 2, 3])
    end

    #
    # == Boolean
    #
    test 'should return true if current controller' do
      assert send(:controller?, 'homes')
    end

    test 'should return false if not current controller' do
      assert_not send(:controller?, 'contacts')
    end

    test 'should return true if current action' do
      assert send(:action?, 'index')
    end

    test 'should return false if not current action' do
      assert_not send(:action?, 'new')
    end

    test 'should return true if blog_categories page' do
      params[:controller] = 'blog_categories'
      params[:action] = 'show'
      assert send(:controller?, 'blogs')
    end

    private

    def initialize_test
      params[:controller] = 'homes'
      params[:action] = 'index'
    end
  end
end
