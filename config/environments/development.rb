require 'vkontakte_api'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => 'mousereminder@gmail.com',
    :password             =>  ENV['EMAIL_PASSWORD'],
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

  VkontakteApi.configure do |config|
    config.api_version = '5.73'
  end

  config.twilio_account_sid = 'AC0cea907e7dafbf6cfa92bf4dd283b033'
  config.twilio_auth_token = '5d471f5cb8a041d5b00ddf88df4be738'

  Geocoder.configure(language: :en)

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  #
  config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]

  config.ykassa_uri = 'https://payment.yandex.net/api/v3/payments'
end
