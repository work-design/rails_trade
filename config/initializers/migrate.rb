TheTrade::Engine.config.paths['db/migrate'].expanded.each do |path|
  Rails.configuration.paths["db/migrate"].push(path)
end