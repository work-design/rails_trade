require 'monetize'
require 'rails_com'
module RailsTrade
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/payment",
      "#{config.root}/app/models/payment_method",
      "#{config.root}/app/models/payout",
      "#{config.root}/app/models/promote_charge",
      "#{config.root}/app/models/promote_good",
      "#{config.root}/app/models/refund"

    ]

    config.eager_load_paths += Dir[
      "#{config.root}/app/models/payment",
      "#{config.root}/app/models/payment_method",
      "#{config.root}/app/models/payout",
      "#{config.root}/app/models/promote_charge",
      "#{config.root}/app/models/promote_good",
      "#{config.root}/app/models/refund"
    ]

    config.generators do |g|
      g.helper false
      g.resource_route false
      g.templates.unshift File.expand_path('lib/templates', RailsCom::Engine.root)
    end

  end
end
