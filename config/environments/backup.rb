# frozen_string_literal: true

# Backup configuration is identical to production, with some overrides
require_relative './production'

Rails.application.configure do
  # Mailer
  config.action_mailer.default_url_options = {
    host: Figaro.env.application_domain_name_backup
  }

  # ActionCable (WebSockets)
  config.action_cable.url = "ws://#{Figaro.env.application_domain_name_backup}/cable"
end

# Set host to links in backup environment
Rails.application.routes.default_url_options = {
  host: Figaro.env.application_host_backup
}
