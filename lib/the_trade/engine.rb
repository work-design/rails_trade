module TheTrade
  class Engine < ::Rails::Engine

    config.eager_load_paths += Dir["#{config.root}/app/models/payments"]
    initializer 'the_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['the_trade_manifest.js']
    end

  end
end

