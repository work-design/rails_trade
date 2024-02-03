module Trade
  module Model::PaymentOrder
    extend ActiveSupport::Concern

    included do
      attribute :payment_amount, :decimal
      attribute :order_amount, :decimal
      attribute :wallet_code, :string

      enum kind: {
        item_amount: 'item_amount',
        overall_additional_amount: 'overall_additional_amount'
      }

      enum state: {
        init: 'init',
        pending: 'pending',
        confirmed: 'confirmed',
        refunded: 'refunded'
      }, _default: 'init', _prefix: true

      belongs_to :user, class_name: 'Auth::User', optional: true

      belongs_to :order, counter_cache: true
      belongs_to :payment, inverse_of: :payment_orders, counter_cache: true, optional: true

      has_one :refund, ->(o) { where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id

      validates :order_id, uniqueness: { scope: :payment_id }, unless: -> { payment_id.nil? }

      after_initialize :init_amount, if: -> { new_record? && payment&.new_record? && payment.wallet_id.blank? }
      after_initialize :init_wallet_code, :init_wallet_amount, if: -> { new_record? && payment&.new_record? && payment.wallet_id.present? }
      before_save :init_user_id, if: -> { user_id.blank? && (changes.keys & ['order_id', 'payment_id']).present? }
      after_update :checked_to_payment!, if: -> { state_confirmed? && (saved_changes.keys & ['state', 'payment_amount']).present? }
      after_update :unchecked_to_payment!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      after_save :pending_to_order!, if: -> { state_pending? && (saved_changes.keys & ['state', 'order_amount']).present? }
      after_save :checked_to_order!, if: -> { state_confirmed? && (saved_changes.keys & ['state', 'order_amount']).present? }
      after_save :unchecked_to_order!, if: -> { state_init? && state_before_last_save == 'confirmed' }
      after_destroy_commit :unchecked_to_order!
    end

    def init_wallet_code
      return unless payment.wallet.wallet_template
      self.wallet_code = payment.wallet.wallet_template.code
    end

    def init_amount
      self.payment_amount = payment.total_amount
      self.order_amount = payment.total_amount
      self.state = 'pending' unless state_changed?
    end

    def init_wallet_amount
      if payment.total_amount.to_d > 0
        init_amount
        return
      end

      if payment.wallet.amount > order_wallet_amount
        self.payment_amount = order_wallet_amount
        self.order_amount = order.amount # todo 为什么之前是 item_amount
      else
        # 当钱包余额够的时候，如果没有指定扣除额度，则将钱包余额全部扣除
        self.payment_amount = payment.wallet.amount
        self.order_amount = wallet_amount_x[0]
      end
      payment.total_amount = self.payment_amount

      self.state = 'pending' unless state_changed?
    end

    def wallet_amount
      r = order.items.map do |item|
        item.parsed_wallet_amount.fetch(wallet_code, {})
      end
      r.compact_blank!
      r
    end

    def order_wallet_amount
      if payment.wallet.is_a?(LawfulWallet)
        order.items.sum(&->(i){ i.amount.to_d })
      else
        wallet_amount.sum(&->(i){ i[:amount].to_d })
      end
    end

    def wallet_amount_x
      x = 0
      y = self.payment_amount
      rest = 0
      result = wallet_amount
      result.sort_by!(&->(i){ i[:rate] }).reverse!
      result.each do |i|
        if y > i[:amount]
          x += i[:rate] * i[:amount]
          y -= i[:amount]
        elsif y == i[:amount]
          x += i[:rate] * i[:amount]
          break
        else
          x += i[:rate] * y
          rest = i[:amount] - y
          break
        end
      end

      [x, rest]
    end

    def init_user_id
      self.user_id = order&.user_id || payment&.user_id
    end

    def checked_to_payment!
      payment.checked_amount += self.payment_amount
      payment.save
    end

    def unchecked_to_payment!
      payment.checked_amount -= self.payment_amount
      payment.save
    end

    def pending_to_order!
      order.received_amount += self.order_amount
      order.save
    end

    def checked_to_order!
      order.user_id = user_id
      order.check_state!
    end

    def unchecked_to_order!
      return if order.blank?
      order.received_amount -= self.order_amount
      order.check_state
      order.save
    end

    def sync_refund_to_order
      order.refunded_amount += self.total_amount
      order.received_amount -= self.total_amount
      order.payment_status = 'refunding'
      order.save
    end

    def order_refund
      order.payment_status = 'refunded'
      order.state = 'canceled'
      order.save
    end

    def refund
      if ['init', 'pending'].include? self.state
        return
      end

      refund = payment.refunds.build(order_id: order_id)
      refund.total_amount = payment_amount
      refund.currency = payment.currency
      refund.save
    end

  end
end
