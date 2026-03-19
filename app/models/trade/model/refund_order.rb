module Trade
  module Model::RefundOrder
    extend ActiveSupport::Concern

    included do
      attribute :payment_amount, :decimal
      attribute :order_amount, :decimal, comment: '对应的订单金额'

      enum :state, {
        init: 'init',
        refunding: 'refunding',
        refunded: 'refunded'
      }, default: 'init', prefix: true

      belongs_to :order, inverse_of: :refund_orders
      belongs_to :payment, inverse_of: :refund_orders
      belongs_to :refund

      has_one :payment_order, primary_key: [:order_id, :payment_id], foreign_key: [:order_id, :payment_id]

      has_many :refunds, foreign_key: :payment_id, primary_key: :payment_id

      after_initialize :init_amount, if: :new_record?
      after_initialize :sync_from_refund, if: :new_record?
      after_save :refunding_to_payment_and_order!, if: -> { state_refunding? && (saved_changes.keys & ['state', 'payment_amount', 'order_amount']).present? }
      after_save :refunded_to_payment_and_order!, if: -> { state_refunded? && (saved_changes.keys & ['state', 'payment_amount', 'order_amount']).present? }
      after_save :revert_to_payment_and_order!, if: -> { state_init? && state_before_last_save == 'refunding' }
      after_destroy_commit :revert_to_payment_and_order!
    end

    def init_amount
      refund.total_amount = refund.total_amount.to_d + payment_amount
    end

    def sync_from_refund
      self.payment = refund.payment
    end

    def refunding_to_payment_and_order!
      payment.refunded_amount += self.payment_amount
      payment.pay_state = 'refunding'

      order.refunded_amount += self.order_amount
      order.unreceived_amount = order.amount - order.received_amount - order.refunded_amount
      order.payment_status = 'refunding'

      self.class.transaction do
        payment.save!
        order.save!
      end
    end

    def refunded_to_payment_and_order!
      payment.pay_state = 'refunded'
      order.payment_status = 'refunded'
      payment_order.state = 'refunded' if payment_order

      self.class.transaction do
        payment.save!
        payment_order.save! if payment_order
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
