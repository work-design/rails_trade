module WxpayConfig
  extend self
  
  def filter(appid)
    configs = Rails.application.credentials.config.dig(:wxpay, Rails.env.to_sym)
    if configs.ia_a?(Array)
      configs.find { |_, v| v[:appid] == appid if v.is_a?(Hash) }
    end
  end

end
