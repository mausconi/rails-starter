# frozen_string_literal: true

#
# MyDevise Mailer
# =================
class MyDeviseMailer < Devise::Mailer
  # Callbacks
  before_action :set_setting

  def password_change(record, opts = {})
    fix_headers(opts)
    super
  end

  def reset_password_instructions(record, token, opts = {})
    fix_headers(opts)
    super
  end

  private

  def set_setting
    @setting = Setting.first
  end

  def fix_headers(opts)
    opts[:from] = @from_admin
    opts[:reply_to] = @from_admin
  end
end
