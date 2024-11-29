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
      belongs_to :payment, counter_cache: true

      has_many :items, primary_key: :order_id, foreign_key: :order_id
      has_many :refunds, primary_key: :payment_id, foreign_key: :payment_id
      has_many :refund_orders, primary_key: [:order_id, :payment_id], foreign_key: [:order_id, :payment_id]

      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      after_initialize :init_amount, if: -> { new_record? && payment&.new_record? }
      #after_update :unchecked_to_payment!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      #after_save :unchecked_to_order!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      after_destroy_commit :unchecked_to_order!
    end

    def init_amount
      if payment.is_a?(WalletPayment)
        if payment.wallet.is_a?(CustomWallet)
          wallet_code = payment.wallet.wallet_template.code
          wallet_amount = order.wallet_amount(wallet_code)  # 将订单金额换算至钱包对应单位
          # 当钱包额度大于订单金额
          if payment.wallet.amount > wallet_amount
            self.payment_amount = wallet_amount
          else
            # 当钱包余额小于订单金额，如果没有指定扣除额度，则将钱包余额全部扣除
            self.payment_amount = payment.wallet.amount
            self.order_amount = order.partly_wallet_amount(wallet_code, payment_amount)
          end
        elsif payment.wallet.is_a?(LawfulWallet)
          if payment.wallet.amount < order_amount
            self.order_amount = payment.wallet.amount
          end
          self.payment_amount = self.order_amount
        end
      else
        self.payment_amount = self.order_amount
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
