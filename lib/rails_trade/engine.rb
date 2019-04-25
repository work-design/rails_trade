require 'monetize'
module RailsTrade
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/payment_interface",
      "#{config.root}/app/models/services",
      "#{config.root}/app/models/payments",
      "#{config.root}/app/models/payment_methods",
      "#{config.root}/app/models/refunds",
      "#{config.root}/app/models/promotes",
      "#{config.root}/app/models/serves",
      "#{config.root}/app/models/promote_charges",
      "#{config.root}/app/models/serve_charges"
    ]

    initializer 'rails_trade.assets.precompile' do |app|
      app.config.assets.precompile += ['rails_trade_manifest.js']
    end

    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.irregular 'serve', 'serves'
    end

  end
end
