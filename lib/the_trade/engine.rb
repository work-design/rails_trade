module TheTrade
  class Engine < ::Rails::Engine

    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/concerns"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/payments"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/payment_methods"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/charges"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/refunds"]
    config.eager_load_paths += Dir["#{config.root}/app/models/the_trade/promotes"]
    initializer 'the_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['the_trade_manifest.js']
    end

  end
end
