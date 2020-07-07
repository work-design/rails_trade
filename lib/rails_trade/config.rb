require 'active_support/configurable'

module RailsTrade
  include ActiveSupport::Configurable

  configure do |config|
    config.default_currency = 'CNY'
    config.disabled_models = []

    config.expire_after = 2.hour
  end

end
