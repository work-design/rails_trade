module WxpayConfig

  def self.filter(appid)
    r = Rails.application.credentials.config.find { |_, v| v[:appid] == appid if v.is_a?(Hash) }
    r[1]
  end

end unless RailsTrade.config.disabled_models.include?('WxpayConfig')
