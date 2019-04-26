require 'monetize'
module RailsTrade
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/payment",
      "#{config.root}/app/models/payment_method",
      "#{config.root}/app/models/promote",
      "#{config.root}/app/models/promote_charge",
      "#{config.root}/app/models/refund",
      "#{config.root}/app/models/serve",
      "#{config.root}/app/models/serve_charge"
    ]

    initializer 'rails_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['rails_trade_manifest.js']
    end

    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.irregular 'serve', 'serves'
    end

  end
end
