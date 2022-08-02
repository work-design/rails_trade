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
      attribute :trade_items_count, :integer, default: 0
      attribute :paid_at, :datetime, index: true
      attribute :pay_deadline_at, :datetime
      attribute :pay_later, :boolean, default: false
      attribute :collectable, :boolean, default: false

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

      belongs_to :produce_plan, class_name: 'Factory::ProducePlan', optional: true  # 统一批次号

      belongs_to :current_cart, class_name: 'Cart', optional: true
      belongs_to :payment_strategy, optional: true

      has_many :carts, ->(o){ where(organ_id: [o.organ_id, nil], member_id: [o.member_id, nil]) }, primary_key: :user_id, foreign_key: :user_id

      has_many :refunds, inverse_of: :order, dependent: :nullify
      has_many :payment_orders, -> { includes(:payment) }, dependent: :destroy_async
      has_many :payments, through: :payment_orders, inverse_of: :orders
      has_many :promote_goods, -> { available }, foreign_key: :user_id, primary_key: :user_id
      has_many :promotes, through: :promote_goods
      has_many :trade_items, inverse_of: :order
      has_many :cart_promotes, autosave: true, dependent: :nullify  # overall can be blank
      accepts_nested_attributes_for :trade_items, reject_if: ->(attributes){ attributes['good_name'].blank? && attributes['good_id'].blank? }
      accepts_nested_attributes_for :cart_promotes

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

      after_initialize :sync_from_current_cart, if: -> { current_cart_id.present? && new_record? }
      before_validation :init_from_member, if: -> { member && member_id_changed? }
      before_validation :init_uuid, if: -> { uuid.blank? }
      after_validation :sum_amount, if: :new_record? # 需要等 trade_items 完成计算
      before_save :init_serial_number, if: -> { paid_at.present? && paid_at_changed? }
      after_create_commit :confirm_ordered!
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

    def init_pay_later
      self.pay_later = true if should_pay_later?
    end

    def should_pay_later?
      trade_items.pluck(:aim).include?('rent')
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
      current_cart.trade_items.each do |trade_item|
        trade_item.order = self
        trade_item.status = 'ordered'
        trade_item.address_id = address_id
      end
    end

    def sync_items_from_organ
      current_cart.organ_trade_items.each do |trade_item|
        trade_item.order = self
        trade_item.status = 'ordered'
        trade_item.address_id = address_id
      end
    end

    def subject
      r = trade_items.map { |oi| oi.good.name.presence }.join(', ')
      r.presence || 'goods'
    end

    def user_name
      user&.name.presence || "#{user_id}"
    end

    def to_cpcl
      cpcl = BaseCpcl.new
      cpcl.text uuid
      cpcl.text "#{from_station&.name || from_address&.area&.full_name} -> #{station&.name || address&.area&.full_name}"
      cpcl.bold_text "#{address.contact}", font: 7, size: 1, line_add: false
      cpcl.text "#{address.tel}", x: 24 * (address.contact.size + 1)
      cpcl.line
      cpcl.text "下单时间：#{created_at.to_fs(:db)}"
      cpcl.right_qrcode(enter_url)
      cpcl.render
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

    def can_cancel?
      init? && ['unpaid', 'to_check'].include?(self.payment_status)
    end

    def amount_money
      amount_to_money(self.currency)
    end

    def available_promotes
      promotes = {}

      trade_items.each do |item|
        item.available_promotes.each do |promote_id, detail|
          promotes[promote_id] ||= []
          promotes[promote_id] << detail
        end
      end

      promotes.transform_keys!(&->(i){ Promote.find(i) })
    end

    def sum_amount
      self.item_amount = trade_items.sum(&:amount)
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)
    end

    def confirm_ordered!
      self.trade_items.update(status: 'ordered')
    end

    def compute_received_amount
      _received_amount = self.payment_orders.select(&->(o){ o.confirmed? }).sum(&:check_amount)
      _refund_amount = self.refunds.where.not(state: 'failed').sum(:total_amount)
      _received_amount - _refund_amount
    end

  end
end
