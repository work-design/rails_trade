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
      belongs_to :payment
      belongs_to :refund

      has_many :refunds, foreign_key: :payment_id, primary_key: :payment_id

      after_initialize :init_amount, if: -> { new_record? }
      #after_update :checked_to_payment!, if: -> { state_confirmed? && (saved_changes.keys & ['state', 'payment_amount']).present? }
      #after_update :unchecked_to_payment!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      #after_destroy_commit :unchecked_to_order!
    end

    def init_amount

    end

    def checked_to_payment!
      payment.checked_amount += self.payment_amount
      payment.save
    end

    def unchecked_to_payment!
      payment.checked_amount -= self.payment_amount
      payment.save
    end

    def update_order_received_amount
      order.received_amount += self.order_amount
      order.unreceived_amount = order.amount - order.received_amount
    end

    def unchecked_to_order!
      return if order.blank?
      order.received_amount -= self.order_amount
      order.check_state
      order.save
    end

  end
end
