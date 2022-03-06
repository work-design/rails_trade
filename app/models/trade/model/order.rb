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

      belongs_to :payment_strategy, optional: true

      has_many :payment_orders, dependent: :destroy_async
      has_many :payments, through: :payment_orders, inverse_of: :orders
      has_many :refunds, inverse_of: :order, dependent: :nullify
      has_many :promote_goods, -> { available }, foreign_key: :user_id, primary_key: :user_id
      has_many :promotes, through: :promote_goods
      has_many :trade_items, ->(o) { where(user_id: o.user_id) }, inverse_of: :order
      has_many :trade_promotes, -> { where(trade_item_id: nil) }, autosave: true, dependent: :nullify  # overall can be blank
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
      before_save :compute_amount
      before_save :check_state, if: -> { amount.zero? }
      after_create_commit :confirm_ordered!
      after_save_commit :confirm_paid!, if: -> { all_paid? && saved_change_to_payment_status? }
      after_save_commit :confirm_part_paid!, if: -> { part_paid? && saved_change_to_payment_status? }
    end

    def init_from_member
      self.user = member.user
      self.member_organ_id = member.organ_id
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
