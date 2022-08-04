module Trade
  module Model::PaymentOrder
    extend ActiveSupport::Concern

    included do
      attribute :check_amount, :decimal
      attribute :kind, :string

      enum state: {
        init: 'init',
        pending: 'pending',
        confirmed: 'confirmed'
      }, _default: 'init'

      belongs_to :user, class_name: 'Auth::User', optional: true

      belongs_to :order, inverse_of: :payment_orders
      belongs_to :payment, inverse_of: :payment_orders, counter_cache: true, optional: true

      has_one :refund, ->(o){ where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id

      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      before_save :init_user_id, if: -> { user_id.blank? && (changes.keys & ['order_id', 'payment_id']).present? }
      after_update :checked_to_payment, if: -> { confirmed? && (saved_changes.keys & ['state', 'check_amount']).present? }
      after_update :unchecked_to_payment, if: -> { init? && state_before_last_save == 'confirmed' }
      after_save :checked_to_order, if: -> { confirmed? && (saved_changes.keys & ['state', 'check_amount']).present? }
      after_save :unchecked_to_order, if: -> { init? && state_before_last_save == 'confirmed' }
      after_destroy_commit :unchecked_to_order
    end

    def init_user_id
      self.user_id = order&.user_id || payment&.user_id
    end

    def checked_to_payment
      payment.checked_amount += self.check_amount
      payment.check_state
      payment.save
    end

    def unchecked_to_payment
      payment.checked_amount -= self.check_amount
      payment.check_state
      payment.save
    end

    def checked_to_order
      order.received_amount += self.check_amount
      order.check_state
      order.save
    end

    def unchecked_to_order
      return if order.blank?
      order.received_amount -= self.check_amount
      order.check_state
      order.save
    end

    def refund
      if ['init', 'pending'].include? self.state
        return
      end

      refund = payment.refunds.build(order_id: order_id)
      refund.total_amount = check_amount
      refund.currency = payment.currency
      refund.save
    end

  end
end
