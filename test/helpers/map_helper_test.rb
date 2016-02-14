require 'test_helper'

#
# == OptionalModules namespace
#
module OptionalModules
  #
  # == MapHelper Test
  #
  class MapHelperTest < ActionView::TestCase
    include Gon::ControllerHelpers
    include Rails.application.routes.url_helpers

    attr_reader :request

    setup :initialize_test

    test 'should return correct gon object map params' do
      set_figaro_datas
      params = {
        mapbox_username: 'tester',
        mapbox_key: '6613337bcb5d9e60dc98',
        mapbox_access_token: 'lr.df00e91d9ef32fdf3d17990d96a8247b35b979f74a3f90fabbb111',
        latitude: nil,
        longitude: nil,
        marker_icon: 'park',
        marker_color: '#EE903E',
        root_url: '/'
      }
      assert_equal params, mapbox_gon_params
    end

    test 'should return correct gon object if marker changed' do
      @map_setting.update_attributes(marker_icon: 'car', marker_color: '#FFF000')
      set_figaro_datas
      params = {
        mapbox_username: 'tester',
        mapbox_key: '6613337bcb5d9e60dc98',
        mapbox_access_token: 'lr.df00e91d9ef32fdf3d17990d96a8247b35b979f74a3f90fabbb111',
        latitude: nil,
        longitude: nil,
        marker_icon: 'car',
        marker_color: '#FFF000',
        root_url: '/'
      }
      assert_equal params, mapbox_gon_params
    end

    private

    def env
    end

    def set_figaro_datas
      ENV['mapbox_username'] = 'tester'
      ENV['mapbox_map_key'] = '6613337bcb5d9e60dc98'
      ENV['mapbox_access_token'] = 'lr.df00e91d9ef32fdf3d17990d96a8247b35b979f74a3f90fabbb111'
    end

    def initialize_test
      @map_setting = map_settings(:one)
    end
  end
end
