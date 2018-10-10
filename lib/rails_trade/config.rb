require 'active_support/configurable'

module RailsTrade
  include ActiveSupport::Configurable

  configure do |config|
    config.admin_class = 'AdminController'
    config.my_class = 'MyController'
    config.default_currency = 'CNY'
    config.disabled_models = []
  end

end
