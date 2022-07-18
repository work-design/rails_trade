module Trade
  module Model::PaymentOrder
    extend ActiveSupport::Concern

    included do
      attribute :check_amount, :decimal, default: 0

      enum state: {
        init: 'init',
        confirmed: 'confirmed'
      }, _default: 'init'

      belongs_to :order, inverse_of: :payment_orders
      belongs_to :payment, inverse_of: :payment_orders
      has_one :refund, ->(o){ where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id

      #validate :valid_check_amount
      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      before_validation :checked_payment, if: -> { confirmed? && (changes.keys & ['state', 'check_amount']).present? }
      before_validation :unchecked_payment, if: -> { init? && state_was == 'confirmed' }
      after_destroy_commit :unchecked_to_order
    end

    def valid_check_amount
      if the_payment_amount > payment.total_amount + payment.adjust_amount
        self.errors.add(:check_amount, 'Total checked amount greater than payment\'s amount')
      end

      if the_order_amount > order.amount + order.adjust_amount
        self.errors.add(:check_amount, 'Total checked amount greater than Order\'s amount')
      end
    end

    def checked_payment
      checked_to_payment
      checked_to_order
    end

    def checked_to_payment
      payment.checked_amount += self.check_amount
      payment.check_state
    end

    def checked_to_order
      order.received_amount += self.check_amount
      order.check_state
    end

    def unchecked_payment
      unchecked_to_payment
      unchecked_to_order
    end

    def unchecked_to_payment
      payment.checked_amount -= self.check_amount
      payment.check_state
    end

    def unchecked_to_order
      return if order.blank?
      order.received_amount -= self.check_amount
      order.check_state
    end

    def confirm!
      self.state = 'confirmed'
      self.save!
    end

    def revert_confirm!
      self.state = 'init'
      self.save!
    end

  end
end
