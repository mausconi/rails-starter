# frozen_string_literal: true
require_relative 'boot'
require 'rails/all'

ActiveSupport::Deprecation.debug = true if ENV['SHOW_DEPRECATION']

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Starter
  #
  # == Application
  #
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Paris'
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.default_locale = :fr
    config.i18n.locale = :fr
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr, :en]
    config.i18n.fallbacks = true
    # config.i18n.enforce_available_locales = false

    config.autoload_paths += Dir["#{config.root}/app/controllers/**/"]
    config.autoload_paths += Dir["#{config.root}/app/models/**/"]
    config.autoload_paths += Dir["#{config.root}/app/decorators/**/"]
    config.autoload_paths += Dir["#{config.root}/app/admin/**/"]
    config.autoload_paths += Dir["#{config.root}/app/jobs/**/"]
    config.autoload_paths += Dir["#{config.root}/app/sweepers/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]

    # Remove Helper, CSS, Coffee generating when scaffolding ressources
    config.generators.helper = false
    config.generators.stylesheets = false
    config.generators.javascripts = false

    # Mailer
    config.active_job.queue_adapter = :delayed_job
    config.action_mailer.default charset: 'utf-8'

    # Set Devise email layout
    config.to_prepare do
      Devise::Mailer.layout 'mailers/default' # default.html.inky
    end

    # Override default errors
    config.exceptions_app = routes
  end
end
