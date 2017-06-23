require 'active_support/configurable'

module TheTrade
  include ActiveSupport::Configurable

  configure do |config|
    config.admin_class = 'Admin::BaseController'
    config.my_class = 'My::BaseController'
  end

end