module TheTrade
  class Engine < ::Rails::Engine

    config.eager_load_paths += Dir["#{config.root}/app/models/payments"]

  end
end
