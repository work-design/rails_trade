class PaymentStrategy < ApplicationRecord


  def credit?
    self.period.to_i > 0
  end

end unless RailsTrade.config.disabled_models.include?('PaymentStrategy')


# :name, comment: '名称'
# :period, comment: '可延期时间，单位天'

# 预付全款
# 预付定金
# 后付