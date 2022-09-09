module Trade
  module Model::Order
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :note, :string
      attribute :expire_at, :datetime, default: -> { Time.current + RailsTrade.config.expire_after }
      attribute :serial_number, :string
      attribute :extra, :json, default: {}
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :items_count, :integer, default: 0
      attribute :paid_at, :datetime, index: true
      attribute :pay_deadline_at, :datetime
      attribute :pay_later, :boolean, default: false
      attribute :pay_auto, :boolean, default: false
      attribute :amount, :decimal
      attribute :received_amount, :decimal
      attribute :unreceived_amount, :decimal

      enum generate_mode: {
        myself: 'myself',
        by_from: 'by_from'
      }, _default: 'myself'

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

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :station, class_name: 'Ship::Station', optional: true

      belongs_to :from_user, class_name: 'Auth::User', optional: true
      belongs_to :from_member, class_name: 'Org::Member', optional: true
      belongs_to :from_member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :from_address, class_name: 'Profiled::Address', optional: true
      belongs_to :from_station, class_name: 'Ship::Station', optional: true

      belongs_to :agent, class_name: 'Org::Member', optional: true
      belongs_to :produce_plan, class_name: 'Factory::ProducePlan', optional: true  # 统一批次号

      belongs_to :current_cart, class_name: 'Cart', optional: true
      belongs_to :payment_strategy, optional: true

      has_one :lawful_wallet, ->(o) { where(o.filter_hash) }, primary_key: :user_id, foreign_key: :user_id
      has_many :carts, ->(o) { where(organ_id: [o.organ_id, nil], member_id: [o.member_id, nil]) }, primary_key: :user_id, foreign_key: :user_id

      has_many :refunds, inverse_of: :order, dependent: :nullify
      has_many :payment_orders, dependent: :destroy_async
      accepts_nested_attributes_for :payment_orders
      has_many :payments, through: :payment_orders, inverse_of: :orders
      has_many :cards, ->(o) { includes(:card_template).where(o.filter_hash) }, primary_key: :user_id, foreign_key: :user_id
      has_many :wallets, ->(o) { includes(:wallet_template).where(o.filter_hash) }, class_name: 'CustomWallet', primary_key: :user_id, foreign_key: :user_id
      has_many :promote_goods, -> { available }, primary_key: :user_id, foreign_key: :user_id
      has_many :promotes, through: :promote_goods
      has_many :items, inverse_of: :order
      has_many :available_item_promotes, -> { includes(:promote) }, through: :items, source: :item_promotes
      accepts_nested_attributes_for :items, reject_if: ->(attributes) { attributes.slice('good_name', 'good_id', 'single_price').compact.blank? }
      has_many :cart_promotes, dependent: :nullify  # overall can be blank
      accepts_nested_attributes_for :cart_promotes

      scope :credited, -> { where(payment_strategy_id: PaymentStrategy.where.not(period: 0).pluck(:id)) }
      scope :to_pay, -> { where(payment_status: ['unpaid', 'part_paid']) }

      after_initialize :sync_from_current_cart, if: -> { current_cart_id.present? && new_record? }
      before_validation :init_from_member, if: -> { member && member_id_changed? }
      before_validation :init_uuid, if: -> { uuid.blank? }
      after_validation :sum_amount, if: :new_record? # 需要等 items 完成计算
      before_save :init_serial_number, if: -> { paid_at.present? && paid_at_changed? }
      before_save :sync_user_from_address, if: -> { user_id.blank? && address_id.present? && address_id_changed? }
      before_save :check_state, if: -> { !pay_later && amount.zero? }
      before_save :compute_pay_deadline_at, if: -> { payment_strategy_id && payment_strategy_id_changed? }
      before_save :compute_unreceived_amount, if: -> { (changes.keys & ['amount', 'received_amount']).present? }
      after_save :confirm_paid!, if: -> { all_paid? && saved_change_to_payment_status? }
      after_save :confirm_part_paid!, if: -> { part_paid? && saved_change_to_payment_status? }
      after_save :confirm_refund!, if: -> { refunding? && saved_change_to_payment_status? }
      after_save :sync_to_unpaid_payment_orders, if: -> { (saved_changes.keys & ['overall_additional_amount', 'item_amount']).present? }
      after_save_commit :lawful_wallet_pay, if: -> { pay_auto? && saved_change_to_pay_auto? }
    end

    def filter_hash
      if user_id
        { organ_id: organ_id, member_id: member_id }
      elsif client_id
        { organ_id: organ_id, member_id: member_id, client_id: client_id }
      else
        { organ_id: organ_id, member_id: member_id }
      end
    end

    def init_uuid
      self.uuid = UidHelper.nsec_uuid('OD')
      self
    end

    def init_from_member
      self.user = member.user
      self.member_organ_id = member.organ_id
      self
    end

    def init_serial_number
      last_item = self.class.where(organ_id: self.organ_id).default_where('paid_at-gte': paid_at.beginning_of_day, 'paid_at-lte': paid_at.end_of_day).order(paid_at: :desc).first

      if last_item
        self.serial_number = last_item.serial_number.to_i + 1
      else
        self.serial_number = (paid_at.strftime('%Y%j') + '0001').to_i
      end
    end

    def sync_user_from_address
      return unless address
      self.user_id = address.account&.user_id
      self.generate_mode = 'by_from'
    end

    def init_pay_later
      self.pay_later = true if should_pay_later?
    end

    def sync_from_current_cart
      return unless current_cart
      self.address_id ||= current_cart.address_id
      self.pay_later = true if current_cart.aim == 'rent'
      if current_cart.user_id.blank?
        sync_items_from_organ
      else
        sync_items_from_user
      end
      current_cart.cart_promotes.each do |cart_promote|
        cart_promote.order = self
        cart_promote.status = 'ordered'
      end
    end

    def sync_items_from_user
      current_cart.items.each do |item|
        sync_item(item)
      end
    end

    def sync_items_from_organ
      current_cart.organ_items.each do |item|
        sync_item(item)
      end
    end

    def sync_item(item)
      item.order = self
      item.address_id = address_id

      if pay_later
        item.status = 'pay_later'
      else
        item.status = 'ordered'
      end
    end

    def sync_to_unpaid_payment_orders
      (saved_changes.keys & ['overall_additional_amount', 'item_amount']).each do |item|
        p = payment_orders.find(&->(i){ i.kind == item })
        next unless p
        p.order_amount = self.send(item) if ['init'].include?(p.state)
        p.save
      end
    end

    def subject
      r = items.map { |oi| oi.good.name.presence }.join(', ')
      r.presence || 'goods'
    end

    def user_name
      user&.name.presence || "#{user_id}"
    end

    def enter_url
      Rails.application.routes.url_for(controller: 'trade/orders', action: 'qrcode', id: self.id)
    end

    def qrcode_enter_png
      QrcodeHelper.code_png(enter_url, border_modules: 0, fill: 'pink')
    end

    def qrcode_enter_url
      QrcodeHelper.data_url(enter_url)
    end

    def should_pay_later?
      items.pluck(:aim).include?('rent')
    end

    def can_pay?
      ['unpaid', 'to_check', 'part_paid'].include?(self.payment_status) && ['init'].include?(self.state)
    end

    def can_cancel?
      init? && ['unpaid', 'to_check'].include?(self.payment_status)
    end

    def sum_amount
      self.item_amount = items.sum(&->(i){ i.amount.to_d })
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&->(i){ i.amount.to_d })
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&->(i){ i.amount.to_d })
    end

    def confirm_paid!
      self.expire_at = nil
      self.paid_at = Time.current
      self.items.each(&->(i){ i.status = 'paid'})
      self.save
      send_notice
    end

    def confirm_part_paid!
      self.expire_at = nil
      self.paid_at = Time.current
      self.items.each(&->(i){ i.status = 'part_paid'})
      self.save
    end

    def confirm_refund!
      self.items.each(&:confirm_refund!)
    end

    def compute_received_amount
      _received_amount = self.payment_orders.select(&->(o){ o.confirmed? }).sum(&:order_amount)
      _refund_amount = self.refunds.where.not(state: 'failed').sum(:total_amount)
      _received_amount - _refund_amount
    end

    def init_received_amount
      self.payment_orders.state_confirmed.sum(:order_amount)
    end

    def compute_pay_deadline_at
      return unless payment_strategy
      self.pay_deadline_at = (Date.today + payment_strategy.period).end_of_day
    end

    def compute_unreceived_amount
      self.unreceived_amount = self.amount.to_d - self.received_amount.to_d
    end

    def send_notice
      broadcast_action_to(
        self,
        action: :update,
        target: 'order_result',
        partial: 'trade/my/orders/success',
        locals: { model: self }
      )
    end

    def check_state
      if self.received_amount.to_d >= self.amount
        self.payment_status = 'all_paid'
      elsif self.received_amount.to_d > 0 && self.received_amount.to_d < self.amount
        self.payment_status = 'part_paid'
      elsif self.received_amount.to_d <= 0
        self.payment_status = 'unpaid'
      end
    end

    def check_state!
      self.received_amount = init_received_amount
      self.check_state
      self.save!
    end

    def wallet_codes
      codes = items.map(&->(i){ i.wallet_amount.keys }).flatten.uniq
      WalletTemplate.where(code: codes).pluck(:id)
    end

    def lawful_wallet_pay
      return unless can_pay?
      payment_order = payment_orders.build(order_amount: amount, payment_amount: amount)
      payment_order.state = 'confirmed'
      payment = payment_order.build_payment(type: 'Trade::WalletPayment', total_amount: amount)
      payment.wallet = lawful_wallet
      payment.save
      payment
    end

  end
end
