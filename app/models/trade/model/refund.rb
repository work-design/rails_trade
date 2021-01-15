module Trade
  module Model::Refund
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :total_amount, :decimal
      attribute :buyer_identifier, :string
      attribute :comment, :string
      attribute :refunded_at, :datetime
      attribute :reason, :string
      attribute :refund_uuid, :string
      attribute :response, :json

      enum state: {
        init: 'init',
        completed: 'completed',
        failed: 'failed',
        denied: 'denied'
      }, _default: 'init'

      belongs_to :operator, class_name: 'Member', optional: true
      belongs_to :order, inverse_of: :refunds, optional: true
      belongs_to :payment

      validates :payment_id, uniqueness: { scope: :order_id }
      #validate :valid_total_amount

      after_initialize if: -> { new_record? } do
        self.refund_uuid ||= UidHelper.nsec_uuid('RD')
        self.state = :init
      end
      after_save :sync_refund, if: -> { completed? && state_before_last_save == 'init' }
      after_save :deny_refund, if: -> { denied? && state_before_last_save == 'init' }
    end

    def valid_total_amount
      if self.new_record? && total_amount > payment.total_amount
        self.errors.add :total_amount, 'more then order received amount!'
      end
    end

    def currency_symbol
      Money::Currency.new(self.currency).symbol
    end

    def sync_refund
      payment.total_amount -= total_amount
      payment.refunded_amount = total_amount
      payment.save

      if order
        order.payment_status = 'refunded'
        order.save
      end
    end

    def deny_refund
      order.payment_status = 'denied'
      order.save
    end

    def can_refund?
      self.init? && ['all_paid', 'part_paid', 'refunding'].include?(order.payment_status)
    end

  end
end
