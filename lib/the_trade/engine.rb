require 'monetize'
module TheTrade
  class Engine < ::Rails::Engine

    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/concerns"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/payment_interface"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/payments"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/payment_methods"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/refunds"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/promotes"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/serves"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/promote_charges"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/serve_charges"]

    initializer 'the_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['the_trade_manifest.js']
    end

    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.irregular 'serve', 'serves'
    end

  end
end
