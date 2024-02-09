module Trade
  module Model::RefundOrder
    extend ActiveSupport::Concern

    included do
      attribute :payment_amount, :decimal
      attribute :order_amount, :decimal, comment: '对应的订单金额'

      enum state: {
        init: 'init',
        refunding: 'refunding',
        refunded: 'refunded'
      }, _default: 'init', _prefix: true

      belongs_to :order, inverse_of: :refund_orders
      belongs_to :payment, inverse_of: :refund_orders
      belongs_to :refund

      has_many :refunds, foreign_key: :payment_id, primary_key: :payment_id

      after_initialize :init_amount, if: :new_record?
      after_save :sync_to_payment_and_order!, if: -> { state_refunding? && (saved_changes.keys & ['state', 'payment_amount', 'order_amount']).present? }
      after_save :revert_to_payment_and_order!, if: -> { state_init? && state_before_last_save == 'refunding' }
      after_destroy_commit :revert_to_payment_and_order!
    end

    def init_amount
      refund.total_amount = refund.total_amount.to_d + payment_amount
    end

    def sync_to_payment_and_order!
      payment.refunded_amount += self.payment_amount
      payment.pay_state = 'refunded'

      order.refunded_amount += self.order_amount
      order.unreceived_amount = order.amount - order.received_amount - order.refunded_amount
      order.payment_status = 'refunding'

      self.class.transaction do
        payment.save!
        order.save!
      end
    end

    def revert_to_payment_and_order!
      payment.refunded_amount -= self.payment_amount

      order.refunded_amount -= self.order_amount
      order.unreceived_amount = order.amount - order.received_amount - order.refunded_amount
      order.check_state

      self.class.transaction do
        payment.save!
        order.save!
      end
    end

  end
end
