module Trade
  module Model::Order
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :received_amount, :decimal, default: 0
      attribute :payment_id, :integer, comment: 'for paypal'
      attribute :myself, :boolean, default: true
      attribute :note, :string
      attribute :expire_at, :datetime, default: -> { Time.current + RailsTrade.config.expire_after }
      attribute :extra, :json, default: {}
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :trade_items_count, :integer, default: 0

      belongs_to :user, class_name: 'Auth::User'
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :produce_plan, class_name: 'Factory::ProducePlan', optional: true  # 统一批次号

      belongs_to :cart, optional: true
      belongs_to :payment_strategy, optional: true

      has_many :payment_orders, dependent: :destroy_async
      has_many :payments, through: :payment_orders, inverse_of: :orders
      has_many :refunds, dependent: :nullify, inverse_of: :order
      has_many :promote_carts, -> { available }, foreign_key: :cart_id, primary_key: :cart_id, dependent: :destroy_async
      has_many :promotes, through: :promote_carts
      has_many :trade_items, inverse_of: :order, dependent: :destroy_async
      has_many :trade_promotes, -> { where(trade_item_id: nil) }, dependent: :destroy_async  # overall can be blank
      accepts_nested_attributes_for :trade_items
      accepts_nested_attributes_for :trade_promotes

      scope :credited, -> { where(payment_strategy_id: PaymentStrategy.where.not(period: 0).pluck(:id)) }
      scope :to_pay, -> { where(payment_status: ['unpaid', 'part_paid']) }

      enum state: {
        init: 'init',
        done: 'done',
        canceled: 'canceled'
      }, _default: 'init'

      enum payment_status: {
        unpaid: 'unpaid',
        to_check: 'to_check',
        part_paid: 'part_paid',
        all_paid: 'all_paid',
        refunding: 'refunding',
        refunded: 'refunded',
        denied: 'denied'
      }, _default: 'unpaid'

      before_validation :init_from_member, if: -> { member && member_id_changed? }
      before_validation do
        self.uuid ||= UidHelper.nsec_uuid('OD')
      end
      before_save :compute_amount, if: -> { cart.blank? }
      after_create :sync_from_cart, if: -> { cart }
      after_create_commit :confirm_ordered!
    end

    def init_from_member
      self.user = member.user
    end

    def init_from_cart
      self.organ_id = cart.organ_id
      self.user_id = cart.user_id
      self.member_id = cart.member_id
      self.member_organ_id = cart.member_organ_id
      self.address_id = cart.address_id
      self.payment_strategy_id = cart.payment_strategy_id
    end

    def remaining_amount
      amount - received_amount
    end

    def subject
      r = trade_items.map { |oi| oi.good.name.presence }.join(', ')
      r.presence || 'goods'
    end

    def sync_from_cart
      cart.trade_promotes.update_all(order_id: self.id, status: 'ordered')

      self.compute_amount
      self.save
    end

    def user_name
      user&.name.presence || "#{user_id}"
    end

    def can_cancel?
      init? && ['unpaid', 'to_check'].include?(self.payment_status)
    end

    def amount_money
      amount_to_money(self.currency)
    end

    def compute_amount
      self.item_amount = trade_items.sum(&:amount)
      self.overall_additional_amount = trade_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
      self.overall_reduced_amount = trade_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount
    end

    def valid_item_amount
      summed_amount = trade_items.sum(&:amount)

      unless item_amount == summed_amount
        errors.add :item_amount, "Item Amount #{item_amount} not equal #{summed_amount}"
        logger.error "#{self.class.name}: #{error_text}"
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end

    def wxpay_result(app)
      #return self if self.payment_status == 'all_paid'
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {
        mchid: app.mch_id,
        out_trade_no: self.uuid,
      }

      begin
        result = WxPay::Api.order_query params, options
      rescue #todo only net errr
        result = { 'err_code_des' => 'network error' }
      end
      logger.debug "\e[35m  wxpay result: #{result}  \e[0m"

      if result['trade_state'] == 'SUCCESS'
        self.change_to_paid! type: 'Trade::WxpayPayment', payment_uuid: result['transaction_id'], params: result
      else
        self.errors.add :base, result['trade_state_desc'] || result['err_code_des']
      end
    end

    def confirm_ordered!
      self.trade_items.each(&:confirm_ordered!)
    end

    def compute_received_amount
      _received_amount = self.payment_orders.where(state: 'confirmed').sum(:check_amount)
      _refund_amount = self.refunds.where.not(state: 'failed').sum(:total_amount)
      _received_amount - _refund_amount
    end

  end
end
