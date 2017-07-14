class PaymentStrategy < ApplicationRecord


  enum strategy: {
    prepay: 'prepay',
    deposit: 'deposit',
    credit: 'credit'
  }


end


# :name, comment: '名称'
# :strategy, comment: '付款策略'
# :period, comment: '周期，单位天'

# 预付全款
# 预付定金
# 后付