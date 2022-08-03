module Trade
  module Model::PaymentOrder
    extend ActiveSupport::Concern

    included do
      attribute :check_amount, :decimal

      enum state: {
        init: 'init',
        confirmed: 'confirmed'
      }, _default: 'init'

      belongs_to :user, class_name: 'Auth::User', optional: true

      belongs_to :order, inverse_of: :payment_orders
      belongs_to :payment, inverse_of: :payment_orders

      has_one :refund, ->(o){ where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id

      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      after_initialize :init_check_amount, if: :new_record?
      before_validation :checked_to_payment, if: -> { confirmed? && (changes.keys & ['state', 'check_amount']).present? }
      before_validation :unchecked_to_payment, if: -> { init? && state_was == 'confirmed' }
      after_save :checked_to_order, if: -> { confirmed? && (saved_changes.keys & ['state', 'check_amount']).present? }
      after_save :unchecked_to_order, if: -> { init? && state_before_last_save == 'confirmed' }
      after_destroy_commit :unchecked_to_order
    end

    def init_check_amount
      self.check_amount ||= payment.total_amount
      self.user = order.user
    end

    def checked_to_payment
      payment.checked_amount += self.check_amount
      payment.check_state
    end

    def unchecked_to_payment
      payment.checked_amount -= self.check_amount
      payment.check_state
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
