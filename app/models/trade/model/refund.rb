module Trade
  module Model::Refund
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :total_amount, :decimal
      attribute :buyer_identifier, :string
      attribute :comment, :string
      attribute :refunded_at, :datetime
      attribute :reason, :string
      attribute :refund_uuid, :string, default: -> { UidUtil.nsec_uuid('RD') }
      attribute :response, :json

      enum :state, {
        init: 'init',
        completed: 'completed',
        failed: 'failed',
        denied: 'denied'
      }, default: 'init'

      belongs_to :operator, class_name: 'Org::Member', optional: true

      belongs_to :payment

      has_many :refund_orders, dependent: :destroy
      has_many :orders, through: :refund_orders

      accepts_nested_attributes_for :refund_orders

      #validate :valid_total_amount

      before_validation :init_from_payment
      after_save :sync_refund_to_payment_and_order!, if: -> { completed? && state_before_last_save == 'init' }
      after_save :deny_refund, if: -> { denied? && state_before_last_save == 'init' }
    end

    def init_from_payment
      self.currency = payment.currency
    end

    def valid_total_amount
      if self.new_record? && total_amount > payment.total_amount
        self.errors.add :total_amount, 'more then received amount!'
      end
    end

    def currency_symbol
      Money::Currency.new(self.currency).symbol
    end

    def sync_refund_to_payment_and_order!
      refund_orders.each do |refund_order|
        refund_order.state = 'refunded'
        refund_order.save
      end
    end

    def do_refund!(operator)
      self.operator = operator
      self.do_refund
      self.save
    end

    def order_refund
      order.payment_status = 'refunded'
      order.state = 'canceled'
      order.save
    end

    def deny_refund
      order.payment_status = 'denied'
      order.save
    end

    def can_refund?
      self.init?
    end

  end
end
