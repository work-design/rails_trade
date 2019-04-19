require 'active_support/configurable'

module RailsTrade
  include ActiveSupport::Configurable

  configure do |config|
    config.admin_controller = 'AdminController'
    config.my_controller = 'MyController'
    config.default_currency = 'CNY'
    config.disabled_models = []

    config.expire_after = 2.hour
  end

end
