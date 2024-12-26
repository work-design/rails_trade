module Trade
  module Model::Order
    extend ActiveSupport::Concern
    include Inner::Amount
    include Inner::User

    included do
      attribute :uuid, :string
      attribute :note, :string
      attribute :expire_at, :datetime, default: -> { Time.current + RailsTrade.config.expire_after }
      attribute :serial_number, :integer
      attribute :extra, :json, default: {}
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :items_count, :integer, default: 0
      attribute :payment_orders_count, :integer, default: 0
      attribute :paid_at, :datetime, index: true
      attribute :pay_deadline_at, :datetime
      attribute :pay_auto, :boolean, default: false
      attribute :adjust_amount, :decimal
      attribute :received_amount, :decimal, default: 0
      attribute :refunded_amount, :decimal, default: 0
      attribute :unreceived_amount, :decimal
      attribute :payable_amount, :decimal

      enum :aim, {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, default: 'use', prefix: true

      enum :generate_mode, {
        myself: 'myself',
        by_from: 'by_from',
        purchase: 'purchase'
      }, default: 'myself'

      enum :state, {
        init: 'init',
        done: 'done',
        canceled: 'canceled'
      }, default: 'init'

      enum :payment_status, {
        unpaid: 'unpaid',
        to_check: 'to_check',
        part_paid: 'part_paid',
        all_paid: 'all_paid',
        refunding: 'refunding',
        refunded: 'refunded',
        denied: 'denied'
      }, default: 'unpaid'

      belongs_to :address, class_name: 'Ship::Address', optional: true
      belongs_to :station, class_name: 'Ship::Station', optional: true
      belongs_to :operator, class_name: 'Org::Member', optional: true

      belongs_to :from_user, class_name: 'Auth::User', optional: true
      belongs_to :from_member, class_name: 'Org::Member', optional: true
      belongs_to :from_member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :from_address, class_name: 'Ship::Address', optional: true
      belongs_to :from_station, class_name: 'Ship::Station', optional: true

      belongs_to :produce_plan, class_name: 'Factory::ProducePlan', optional: true  # 统一批次号
      belongs_to :provide, class_name: 'Factory::Provide', optional: true

      belongs_to :current_cart, class_name: 'Cart', optional: true
      belongs_to :payment_strategy, optional: true

      has_one :lawful_wallet, ->(o) { where(o.filter_hash) }, primary_key: :user_id, foreign_key: :user_id
      has_many :carts, ->(o) { where(organ_id: [o.organ_id, nil], member_id: [o.member_id, nil]) }, primary_key: :user_id, foreign_key: :user_id

      has_many :payment_orders, inverse_of: :order, dependent: :destroy_async
      has_many :payments, inverse_of: :orders, through: :payment_orders
      has_many :refund_orders, dependent: :destroy_async
      has_many :refunds, through: :refund_orders
      has_many :cards, ->(o) { includes(:card_template).where(o.filter_hash) }, primary_key: :user_id, foreign_key: :user_id
      has_many :wallets, ->(o) { includes(:wallet_template).where(o.filter_hash) }, class_name: 'CustomWallet', primary_key: :user_id, foreign_key: :user_id
      has_many :promote_goods, -> { available }, primary_key: :user_id, foreign_key: :user_id
      has_many :promotes, through: :promote_goods
      has_many :items, inverse_of: :order
      has_many :available_item_promotes, -> { includes(:promote) }, through: :items, source: :item_promotes
      has_many :cart_promotes, dependent: :nullify  # overall can be blank

      accepts_nested_attributes_for :items, reject_if: ->(attributes) { attributes.slice('good_name', 'good_id', 'source_id').compact_blank.blank? || ['0'].include?(attributes['commit']) }
      accepts_nested_attributes_for :cart_promotes
      accepts_nested_attributes_for :payment_orders

      scope :credited, -> { where(payment_strategy_id: PaymentStrategy.where.not(period: 0).pluck(:id)) }
      scope :to_pay, -> { where(payment_status: ['unpaid', 'part_paid']) }

      after_initialize :sync_from_current_cart, if: -> { new_record? && current_cart_id.present? }
      after_initialize :init_uuid, if: -> { uuid.blank? }
      after_initialize :confirm_ordered!, if: :new_record?
      before_validation :sync_organ_from_provide, if: -> { provide_id_changed? }
      after_validation :compute_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount', 'adjust_amount']).present? }
      after_validation :compute_unreceived_amount, if: -> { (changes.keys & ['amount', 'received_amount']).present? }
      before_create :init_payable_amount
      before_save :sync_user_from_address, if: -> { user_id.blank? && address_id.present? && address_id_changed? }
      before_save :check_state, if: -> { amount.to_d.zero? || (changes.keys & ['received_amount']).present? }
      before_save :init_serial_number, if: -> { can_serial_number? }
      before_save :compute_pay_deadline_at, if: -> { payment_strategy_id && payment_strategy_id_changed? }
      after_save :confirm_refund!, if: -> { refunding? && saved_change_to_payment_status? }
      after_save :sync_to_unpaid_payment_orders, if: -> { (saved_changes.keys & ['overall_additional_amount', 'item_amount']).present? }
      after_create :sync_ordered_to_current_cart, if: -> { current_cart_id.present? }
      after_save_commit :lawful_wallet_pay, if: -> { pay_auto && saved_change_to_pay_auto? }
      after_save_commit :send_notice_after_commit, if: -> { saved_change_to_payment_status? }
    end

    def filter_hash
      if user_id
        { organ_id: organ_id, member_id: member_id }
      elsif client_id
        { organ_id: organ_id, member_id: member_id, client_id: client_id }
      elsif contact_id
        { organ_id: organ_id, member_id: member_id, contact_id: contact_id }
      else
        { organ_id: organ_id, member_id: member_id, client_id: client_id, contact_id: contact_id }
      end
    end

    def available_item_promotes
      r = []
      items.each do |item|
        r += item.item_promotes
      end

      r
    end

    def init_uuid
      self.uuid = UidHelper.nsec_uuid('OD')
      self
    end

    def can_serial_number?
      items.map(&:dispatch).include?('dine') || (paid_at.present? && paid_at_was.blank?)
    end

    def init_serial_number
      now = Time.current
      last_item = self.class.where(organ_id: self.organ_id).default_where('created_at-gte': now.beginning_of_day, 'created_at-lte': now.end_of_day).maximum(:serial_number)

      if last_item
        self.serial_number = last_item + 1
      else
        self.serial_number = 1
      end
    end

    def init_payable_amount
      if current_cart&.support_deposit? && amount >= 1
        self.payable_amount = amount * current_cart.deposit_ratio / 100
      elsif advance_amount.to_d > 0
        self.payable_amount = advance_amount
      else
        self.payable_amount = unreceived_amount
      end
    end

    def serial_str
      serial_number ? serial_number.to_s.rjust(3, '0') : ''
    end

    def serial_long_str
      paid_at.strftime('%Y%j') + serial_str
    end

    def sync_organ_from_provide
      self.organ_id = provide.provider_id if provide
    end

    def sync_user_from_address
      return unless address
      self.user_id = address.account&.user_id
      self.generate_mode = 'by_from'
    end

    def need_address?
      current_cart.checked_all_items.map(&:dispatch).include?('delivery')
    end

    def sync_from_current_cart
      self.address_id ||= current_cart.address_id if need_address?
      self.assign_attributes current_cart.attributes.slice('aim', 'payment_strategy_id', 'member_id', 'agent_id', 'contact_id', 'client_id')
      current_cart.checked_all_items.each do |item|
        item.order = self
      end
      current_cart.cart_promotes.each do |cart_promote|
        cart_promote.order = self
      end
    end

    def sync_ordered_to_current_cart
      return unless current_cart
      current_cart.with_lock do
        current_cart.compute_amount!
      end
      carts.where.not(id: current_cart_id).update_all(fresh: false)
    end

    def sync_to_unpaid_payment_orders
      (saved_changes.keys & ['overall_additional_amount', 'item_amount']).each do |item|
        p = payment_orders.find(&->(i){ i.kind == item })
        next unless p
        p.order_amount = self.send(item) if ['init'].include?(p.state)
        p.save
      end
    end

    def ordered_items
      items.select(&:order_effective?)
    end

    def compute_amount
      _ordered_items = ordered_items
      self.item_amount = _ordered_items.sum(&->(i){ i.amount.to_d })
      self.advance_amount = _ordered_items.sum(&->(i){ i.advance_amount.to_d })
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&->(i){ i.amount.to_d })
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&->(i){ i.amount.to_d })
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount + adjust_amount.to_d
    end

    def compute_unreceived_amount
      self.unreceived_amount = amount - received_amount
    end

    def subject
      r = items.map { |oi| oi.good_name.presence }.join(', ')
      r.presence || 'goods'
    end

    def user_name
      user&.name.presence || "#{user_id}"
    end

    def all_purchase?
      items.all?(->(i){ i.purchase_id.present? })
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

    def can_pay?
      ['unpaid', 'to_check', 'part_paid'].include?(self.payment_status) && ['init'].include?(self.state)
    end

    def can_cancel?
      init? && ['unpaid', 'to_check'].include?(self.payment_status)
    end

    def confirm_ordered!
      items.each do |item|
        item.status = 'ordered'
      end
      cart_promotes.each do |cart_promote|
        cart_promote.status = 'ordered'
      end
      compute_amount
    end

    def confirm_paid!
      ordered_items.each do |item|
        item.status = 'deliverable'
      end
    end

    def confirm_part_paid!
      ordered_items.each do |item|
        item.status = 'deliverable'
      end
    end

    def confirm_unpaid!
      ordered_items.each do |item|
        item.status = 'ordered'
      end
    end

    def confirm_refund!
      ordered_items.each do |item|
        item.status = 'refund'
      end
    end

    def compute_pay_deadline_at
      return unless payment_strategy
      self.pay_deadline_at = (Date.today + payment_strategy.period).end_of_day
    end

    def send_notice_after_commit
      if payment_status == 'all_paid'
        send_paid_notice
      elsif payment_status == 'part_paid'
        send_part_paid_notice
      end
    end

    # 在 model 中覆写
    def send_part_paid_notice
      send_notice
    end

    def send_paid_notice
      send_notice
    end

    def send_notice
      return unless id
      broadcast_action_to(
        self,
        action: :append,
        target: 'body',
        partial: 'visit',
        locals: { model: self }
      )
    end

    def check_state
      if self.received_amount.to_d >= self.amount.to_d
        self.payment_status = 'all_paid'
        self.paid_at = Time.current
        self.confirm_paid!
      elsif self.received_amount.to_d > 0 && self.received_amount.to_d < self.amount.to_d
        self.payment_status = 'part_paid'
        self.paid_at = Time.current
        self.confirm_part_paid!
      elsif self.received_amount.to_d <= 0
        self.payment_status = 'unpaid'
        self.paid_at = nil
        self.confirm_unpaid!
      end
      self.expire_at = nil
    end

    def compute_received_amount
      self.received_amount = self.payment_orders.select(&:state_confirmed?).sum(&:order_amount)
    end

    def check_state!
      self.compute_received_amount
      self.refunded_amount = self.refunds.where.not(state: 'failed').sum(:total_amount)
      self.check_state
      self.save!
    end

    def confirm!
      self.class.transaction do
        payment_orders.each { |i| i.state = 'confirmed' }
        self.compute_received_amount
        payment_orders.each do |i|
          i.payment.compute_checked_amount
          i.payment.save!
        end
        self.save!
      end
    end

    def wallet_codes
      codes = items.map(&->(i){ i.wallet_amount.keys }).flatten.uniq
      WalletTemplate.where(code: codes).pluck(:id)
    end

    def parsed_wallet_amount(wallet_code)
      r = items.map do |item|
        item.parsed_wallet_amount.fetch(wallet_code, {})
      end
      r.compact_blank!
      r
    end

    def total_wallet_amount(wallet_code)
      parsed_wallet_amount(wallet_code).sum { |i| i[:amount].to_d }
    end

    # amount 为 wallet 对应单位
    def partly_wallet_amount(wallet_code, amount)
      used = 0
      rest = 0
      result = parsed_wallet_amount(wallet_code)
      result.sort_by!(&->(i){ i[:rate] }).reverse!
      result.each do |i|
        if amount > i[:amount]
          used += i[:rate] * i[:amount]
          amount -= i[:amount]
        elsif amount == i[:amount]
          used += i[:rate] * i[:amount]
          break
        else
          used += i[:rate] * amount
          rest = i[:amount] - amount
          break
        end
      end

      logger.debug "\e[35m  Used: #{used}, Amount: #{amount}, Rest: #{rest}  \e[0m"
      [used, rest]
    end

    def lawful_wallet_pay
      return unless can_pay?
      payment = to_payment(
        type: 'Trade::WalletPayment',
        wallet_id: lawful_wallet.id,
        state: 'confirmed',
        order_amount: unreceived_amount
      )
      payment.save
      payment
    end

    def payment_types
      payment_orders.map { |i| i.payment.type }
    end

    def batch_pending_payments(params)
      params[:payment_orders_attributes].each do |_, po_params|
        if po_params[:state] == 'pending'
          po_params[:payment_attributes].merge! organ_id: organ_id, user_id: user_id
          self.payment_orders.build po_params
        end
      end
      self.received_amount = self.payment_orders.select(&:state_pending?).sum(&:order_amount)
      compute_unreceived_amount
    end

    def init_wallet_payments
      return unless items.map(&:good_type).exclude?('Trade::Advance') && can_pay?

      init_wallet_payment
      return if unreceived_amount <= 0

      if lawful_wallet && payment_orders.map { |i| i.payment.wallet_id }.exclude?(lawful_wallet.id)
        init_lawful_wallet_payment
      end
    end

    def init_hand_payment(state: 'init')
      return if unreceived_amount <= 0
      payment_orders.build(
        order_amount: unreceived_amount,
        payment_amount: unreceived_amount,
        state: state,
        payment_attributes: {
          type: 'Trade::HandPayment'
        }
      )
    end

    def init_wallet_payment
      codes = items.map(&->(i){ i.wallet_amount.keys }).flatten.uniq
      ids = WalletTemplate.where(code: codes).pluck(:id)
      except_ids = payment_orders.map { |i| i.payment.wallet_id }

      wallets.includes(:wallet_template).where.not(id: except_ids).where(wallet_template_id: ids).each do |wallet|
        break if wallet.amount <= 0
        break if unreceived_amount <= 0

        wallet_code = wallet.wallet_template.code
        wallet_amount = total_wallet_amount(wallet_code)  # 将订单金额换算至钱包对应单位
        if wallet.amount > wallet_amount # 当钱包额度大于订单金额
          payment_amount = wallet_amount
        else
          payment_amount = wallet.amount # 当钱包余额小于订单金额，如果没有指定扣除额度，则将钱包余额全部扣除
        end
        order_amount, _ = partly_wallet_amount(wallet_code, payment_amount)

        payment_orders.build(
          order_amount: order_amount,
          payment_amount: payment_amount,
          payment_attributes: {
            type: 'Trade::WalletPayment',
            organ_id: organ_id,
            user_id: user_id,
            wallet_id: wallet.id,
            pay_state: 'paid'
          }
        )
      end
    end

    def init_lawful_wallet_payment
      if lawful_wallet.amount <= 0
        return
      elsif lawful_wallet.amount < unreceived_amount
        order_amount = lawful_wallet.amount
      else
        order_amount = unreceived_amount
      end

      payment_orders.build(
        order_amount: order_amount,
        payment_amount: order_amount,
        payment_attributes: {
          type: 'Trade::WalletPayment',
          organ_id: organ_id,
          user_id: user_id,
          wallet_id: lawful_wallet.id,
          pay_state: 'paid'
        }
      )
    end

    def xx
      unreceived_amount.to_d > 0 && unreceived_amount.to_d <= amount
    end

    def to_payment(type: 'Trade::WxpayPayment', order_amount: payable_amount, payment_amount: order_amount, state: 'init', **options)
      if options.key? :payment_uuid
        payment = payments.find_by(type: type, payment_uuid: options[:payment_uuid])
        return payment if payment
      end

      payment_orders.build(
        state: state,
        order_amount: order_amount,
        payment_amount: payment_amount,
        payment_attributes: {
          type: type,
          organ_id: organ_id,
          user_id: user_id,
          total_amount: payment_amount,
          **options
        }
      )
    end

    def pending_payments
      Payment.to_check.where(organ_id: organ_id, total_amount: amount).default_where('created_at-gte': created_at).order(created_at: :asc)
    end

  end
end
