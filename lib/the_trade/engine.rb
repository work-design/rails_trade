module TheTrade
  class Engine < ::Rails::Engine

    config.eager_load_paths += Dir["#{config.root}/app/models/payments"]
    #config.eager_load_paths += Dir["#{config.root}/app/models/orders"]
    config.eager_load_paths += Dir["#{config.root}/app/models/charges"]
    #config.eager_load_paths += Dir["#{config.root}/app/models/refunds"]
    initializer 'the_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['the_trade_manifest.js']
    end

  end
end

