module Trade
  module Model::PaymentStrategy
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :period, :integer, default: 0, comment: '可延期时间，单位天'

      enum strategy: {
        # 预付全款
        # 预付定金
        # 后付
        spot_payment: 'spot_payment',
        freight_collect: 'freight_collect',
        included_goods: 'included_goods'
      }
    end

    def credit?
      self.period.to_i > 0
    end

  end
end
