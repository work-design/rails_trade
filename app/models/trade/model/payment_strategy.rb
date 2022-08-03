module Trade
  module Model::PaymentStrategy
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :period, :integer, default: 0, comment: '可延期时间，单位天'
      attribute :from_pay, :boolean, default: true

      enum strategy: {
        # 预付全款
        # 预付定金
        # 后付
        spot_payment: 'spot_payment', # 现付
        freight_collect: 'freight_collect', # 运费到付
        included_goods: 'included_goods'
      }

      belongs_to :organ, class_name: 'Org::Organ', optional: true
    end

    def credit?
      self.period.to_i > 0
    end

  end
end
