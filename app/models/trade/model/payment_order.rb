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
      }, default: 'init', prefix: true

      belongs_to :order, inverse_of: :payment_orders, counter_cache: true
      belongs_to :payment, inverse_of: :payment_orders, counter_cache: true

      accepts_nested_attributes_for :payment

      has_many :items, primary_key: :order_id, foreign_key: :order_id
      has_many :refunds, primary_key: :payment_id, foreign_key: :payment_id
      has_many :refund_orders, primary_key: [:order_id, :payment_id], foreign_key: [:order_id, :payment_id]

      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      #after_update :unchecked_to_payment!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      #after_save :unchecked_to_order!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      after_destroy_commit :unchecked_to_order!
    end

    def confirm!
      self.state = 'confirmed'
      payment.compute_checked_amount
      order.compute_received_amount

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

    def refund_by_order(order_amount)

    end

    def refund_by_payment(_refund_amount = payment_amount)
      if ['init', 'pending'].include? self.state
        return
      end

      refund = refunds.find_by(state: 'init') || payment.refunds.build
      refund.refund_orders.build(
        order: order,
        refund: refund,
        payment: payment,
        state: 'refunding',
        payment_amount: _refund_amount,
        order_amount: Rational(order_amount, payment_amount) * _refund_amount
      )
      refund.save!
    end

  end
end
