# frozen_string_literal: true

#
# == Application Mailer
#
class ApplicationMailer < ActionMailer::Base
  helper :html # HtmlHelper

  before_action :set_setting
  before_action :set_map_setting
  before_action :set_contact_settings

  private

  def set_setting
    @setting = Setting.first
  end

  def set_map_setting
    @map_setting = MapSetting.first.decorate
  end

  def set_contact_settings
    @copy_to_sender = false
  end
end
