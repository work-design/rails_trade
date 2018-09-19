require 'monetize'
module RailsTrade
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/rails_trade",
    ]

    config.eager_load_paths += Dir[
      "#{config.root}/app/models/rails_trade/concerns",
      "#{config.root}/app/models/rails_trade/payment_interface",
      "#{config.root}/app/models/rails_trade/payments",
      "#{config.root}/app/models/rails_trade/payment_methods",
      "#{config.root}/app/models/rails_trade/refunds",
      "#{config.root}/app/models/rails_trade/promotes",
      "#{config.root}/app/models/rails_trade/serves",
      "#{config.root}/app/models/rails_trade/promote_charges",
      "#{config.root}/app/models/rails_trade/serve_charges"
    ]

    initializer 'rails_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['rails_trade_manifest.js']
    end

    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.irregular 'serve', 'serves'
    end

  end
end
