require 'monetize'
require 'rails_com'
module RailsTrade
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/payment",
      "#{config.root}/app/models/payment_method",
      "#{config.root}/app/models/payout",
      "#{config.root}/app/models/promote_charge",
      "#{config.root}/app/models/refund",
      "#{config.root}/app/models/wallet"
    ]

    config.eager_load_paths += Dir[
      "#{config.root}/app/models/payment",
      "#{config.root}/app/models/payment_method",
      "#{config.root}/app/models/payout",
      "#{config.root}/app/models/promote_charge",
      "#{config.root}/app/models/refund",
      "#{config.root}/app/models/wallet"
    ]

    config.generators do |g|
      g.helper false
      g.resource_route false
      g.templates.unshift File.expand_path('lib/templates', RailsCom::Engine.root)
    end

    initializer 'rails_trade.assets' do |app|
      app.config.assets.paths << root.join('app/assets/images')
    end

  end
end
