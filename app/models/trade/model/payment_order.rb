module Trade
  module Model::PaymentOrder
    extend ActiveSupport::Concern

    included do
      attribute :payment_amount, :decimal, default: 0
      attribute :order_amount, :decimal, default: 0

      enum :kind, {
        item_amount: 'item_amount',
        overall_additional_amount: 'overall_additional_amount'
      }

      enum :state, {
        init: 'init',
        pending: 'pending',
        confirmed: 'confirmed',
        refunding: 'refunding',
        refunded: 'refunded'
      }, default: 'init', prefix: true

      belongs_to :order, inverse_of: :payment_orders, counter_cache: true
      belongs_to :payment, inverse_of: :payment_orders, counter_cache: true

      has_many :items, primary_key: :order_id, foreign_key: :order_id
      has_many :refunds, primary_key: :payment_id, foreign_key: :payment_id
      has_many :refund_orders, primary_key: [:order_id, :payment_id], foreign_key: [:order_id, :payment_id]

      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      #after_update :unchecked_to_payment!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      #after_save :unchecked_to_order!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      after_destroy_commit :unchecked_to_order!
    end

    def paid?
      ['pending', 'confirmed'].include?(state)
    end

    def confirm!
      self.state = 'confirmed'
      payment.compute_checked_amount
      order.compute_received_amount

      # 扫码收款之后会拿到用户信息，同步至订单
      if order.user_id.blank?
        order.user_id = payment.user_id
      end

      self.class.transaction do
        self.save
        order.save
      end
    end

    def unchecked_to_payment!
      payment.checked_amount -= self.payment_amount
      payment.save
    end

    def unchecked_to_order!
      return if order.blank?
      order.received_amount -= self.order_amount
      order.check_state
      order.save
    end

    def refund_by_order(order_refund = order_amount, uuid: nil)
      payment_refund = Rational(payment_amount, order_amount) * order_refund
      refund_with_transfer(payment_refund, order_refund, uuid: uuid)
    end

    def refund_by_payment(payment_refund = payment_amount, uuid: nil)
      order_refund = Rational(order_amount, payment_amount) * payment_refund
      refund_with_transfer(payment_refund, order_refund, uuid: uuid)
    end

    def refund_with_transfer(payment_total, order_total, uuid:)
      if ['init', 'pending'].include? self.state
        return
      end
      self.state = 'refunding'

      refund = refunds.find_by(state: 'init') || payment.refunds.build(refund_uuid: uuid)
      refund.refund_orders.find_by(order_id: order.id) || refund.refund_orders.build(order_id: order.id, state: 'refunding', payment_amount: payment_total, order_amount: order_total)

      self.class.transaction do
        self.save!
        refund.save!
      end
    end

  end
end
