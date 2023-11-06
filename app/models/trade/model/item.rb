module Trade
  module Model::Item
    PROMOTE_COLUMNS = ['original_amount', 'number', 'weight', 'volume']
    extend ActiveSupport::Concern
    include Inner::User

    included do
      attribute :uuid, :string
      attribute :good_name, :string
      attribute :number, :decimal, default: 1, comment: '数量'
      attribute :done_number, :decimal, default: 0, comment: '已达成交易数量'
      attribute :rest_number, :decimal, as: 'number - done_number', virtual: true
      attribute :weight, :integer, default: 1, comment: '重量'
      attribute :volume, :integer, default: 0, comment: '体积'
      attribute :vip_code, :string
      attribute :single_price, :decimal, default: 0, comment: '一份产品的价格'
      attribute :retail_price, :decimal, default: 0, comment: '单个商品零售价(商品原价 + 服务价)'
      attribute :wholesale_price, :decimal, default: 0, comment: '多个商品批发价'
      attribute :original_amount, :decimal, default: 0, comment: '合计份数之后的价格，商品原价'
      attribute :additional_amount, :decimal, default: 0, comment: '附加服务价格汇总'
      attribute :reduced_amount, :decimal, default: 0, comment: '已优惠的价格'
      attribute :amount, :decimal
      attribute :wallet_amount, :json, default: {}
      attribute :advance_amount, :decimal, default: 0, comment: '预付款'
      attribute :expire_at, :datetime
      attribute :note, :string
      attribute :extra, :json, default: {}
      attribute :holds_count, :integer, default: 0

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered',
        trial: 'trial',
        deliverable: 'deliverable',
        packaged: 'packaged',
        done: 'done',
        canceled: 'canceled',
        expired: 'expired',
        paid: 'paid',
        refund: 'refund'
      }, _default: 'checked', _prefix: true

      enum delivery_status: {
        init: 'init',
        partially: 'partially',
        all: 'all'
      }, _default: 'init', _prefix: true

      enum aim: {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, _default: 'use', _prefix: true

      belongs_to :station, class_name: 'Ship::Station', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :operator, class_name: 'Org::Member', optional: true

      # 仅物流订单，发货方信息
      belongs_to :from_station, class_name: 'Ship::Station', optional: true
      belongs_to :from_address, class_name: 'Profiled::Address', optional: true

      belongs_to :good, polymorphic: true, optional: true
      belongs_to :current_cart, class_name: 'Cart', optional: true  # 下单时的购物车
      belongs_to :order, inverse_of: :items, counter_cache: true, optional: true

      has_one :delivery, ->(o) { where(o.scene_filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_one :organ_delivery, ->(o) { where(o.organ_scene_filter_hash) }, class_name: 'Delivery', primary_key: :organ_id, foreign_key: :organ_id
      has_one :lawful_wallet, ->(o) { where(o.filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id

      has_many :carts, ->(o) { where(o.cart_filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_many :organ_carts, ->(o) { where(member_id: nil, user_id: nil, organ_id: [o.organ_id, nil], good_type: [o.good_type, nil], aim: [o.aim, nil]) }, class_name: 'Cart', primary_key: :member_organ_id, foreign_key: :member_organ_id
      has_many :cards, ->(o) { where(o.filter_hash).effective }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :wallets, ->(o) { where(o.filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :item_promotes, inverse_of: :item, dependent: :destroy
      has_many :payment_orders, primary_key: :order_id, foreign_key: :order_id
      has_many :holds

      has_many :unavailable_promote_goods, ->(o) { unavailable.where(organ_id: o.organ_ancestor_ids, good_id: [o.good_id, nil], aim: o.aim) }, class_name: 'PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :available_promote_goods, ->(o) { effective.where(organ_id: o.organ_ancestor_ids, good_id: [o.good_id, nil], user_id: [o.user_id, nil], member_id: [o.member_id, nil], aim: o.aim) }, class_name: 'PromoteGood', foreign_key: :good_type, primary_key: :good_type

      has_one_attached :image

      scope :carting, -> { where(status: ['init', 'checked', 'trial']) }
      scope :checked, -> { where(status: ['checked', 'trial']) }
      scope :deliverable, -> { where(status: ['deliverable', 'packaged']) }
      scope :packable, -> { where(status: ['paid']) }
      scope :packaged, -> { where(status: ['packaged', 'done']) }

      acts_as_notify(
        :default,
        only: [:good_name, :number, :amount, :note],
        methods: [:order_uuid, :cart_organ]
      )

      before_validation :init_uuid, if: :new_record?
      before_validation :sync_from_current_cart, if: -> { current_cart && current_cart_id_changed? }
      before_validation :sync_from_good, if: -> { good_id.present? && good_id_changed? }
      before_validation :compute_price, if: -> { good_id_changed? || purchase_id_changed? }
      before_validation :compute_amount, if: -> { (changes.keys & ['number', 'single_price']).present? }
      before_validation :init_delivery, if: -> { (changes.keys & ['user_id', 'member_id', 'organ_id']).present? }
      before_validation :init_organ_delivery, if: -> { (changes.keys & ['member_organ_id']).present? }
      before_save :set_wallet_amount, if: -> { (changes.keys & ['number', 'single_price']).present? }
      before_save :sync_from_order, if: -> { order_id.present? && order_id_changed? }
      before_create :add_promotes
      before_update :reset_promotes, if: -> { (changes.keys & PROMOTE_COLUMNS).present? }
      after_create :clean_when_expired, if: -> { expire_at.present? }
      after_save :sync_amount_to_current_cart, if: -> { current_cart_id.present? && (saved_changes.keys & ['amount', 'status']).present? && ['init', 'checked', 'trial', 'expired'].include?(status) }
      after_save :order_work, if: -> { saved_change_to_status? && ['ordered', 'trial', 'deliverable', 'done', 'refund'].include?(status) }
      after_save :set_not_fresh, if: -> { current_cart_id.blank? || (saved_changes.keys & ['current_cart_id', 'amount']).present? || (saved_change_to_status? && status == 'ordered') }
      after_save :sync_ordered_to_current_cart, if: -> { current_cart_id.present? && (saved_change_to_status? && status == 'ordered') }
      after_destroy :remove_promotes
      after_destroy :order_pruned!
      after_destroy :sync_amount_to_current_cart, if: -> { current_cart_id.present? && ['checked', 'trial'].include?(status) }
    end

    def cart_filter_hash
      options = { good_type: [good_type, nil], aim: [aim, nil] }
      if member_id
        options.merge! member_id: [member_id, nil], member_organ_id: member_organ_id
      elsif user_id
        options.merge! user_id: [user_id, nil]
      elsif client_id
        options.merge! client_id: client_id
      else
        options
      end
    end

    def filter_hash
      if member_id
        { member_id: member_id }
      elsif client_id
        { client_id: client_id }
      else
        { user_id: user_id }
      end
    end

    def full_filter_hash
      if user_id
        { organ_id: organ_id, user_id: user_id, member_id: member_id }
      elsif client_id
        { organ_id: organ_id, member_id: member_id, client_id: client_id }
      else
        { organ_id: organ_id, member_id: member_id }
      end
    end

    def scene_filter_hash
      filter_hash.merge! produce_on: produce_on, scene_id: scene_id
    end

    def organ_scene_filter_hash
      o = { member_organ_id: member_organ_id }
      o.merge! produce_on: produce_on, scene_id: scene_id
    end

    def effective?
      ['checked', 'trial'].include?(status) && !destroyed?
    end

    def init_uuid
      self.uuid = UidHelper.nsec_uuid('ITEM')
    end

    def init_delivery
      return if produce_on.blank? && scene_id.blank?
      delivery || build_delivery
    end

    def init_organ_delivery
      return if produce_on.blank? && scene_id.blank?
      organ_delivery || build_organ_delivery
    end

    def organ_ancestor_ids
      return [] unless organ
      organ.self_and_ancestor_ids
    end

    def sync_from_good
      return unless good
      self.good_name = good.name
      self.extra = Hash(self.extra).merge good.item_extra
      self.organ_id = (good.respond_to?(:organ_id) && good.organ_id) || current_cart&.organ_id
      self.produce_on = good.produce_on if good.respond_to? :produce_on
    end

    def sync_from_current_cart
      self.aim = current_cart.aim if good_type != 'Trade::Purchase'
      self.good_type ||= current_cart.good_type
    end

    def sync_from_order
      return unless order
      self.organ_id ||= order.organ_id
      self.user_id ||= order.user_id
      self.address_id = order.address_id
      self.station_id = order.station_id
      self.from_address_id = order.from_address_id
      self.from_station_id = order.from_station_id
    end

    def set_wallet_amount
      return unless good
      if ['use', 'invest'].include?(aim)
        self.wallet_amount = good.wallet_price.transform_values(&->(v){ v.to_d * number })
      end
    end

    def parsed_wallet_amount
      wallet_amount.transform_values(&->(v){ { rate: Rational(original_amount.to_s, v), amount: v.to_d }})
    end

    def compute_price
      if good
        min = good.card_price.slice(*cards.includes(:card_template).map(&->(i){ i.card_template.code })).min
        if min.present?
          self.vip_code = min[0]
          self.single_price = min[1]
        else
          self.vip_code = nil
          self.single_price = good.price
        end
      elsif purchase
        self.single_price = purchase.cost_price
      end
    end

    def compute_price!
      compute_price
      save
    end

    def untrial
      destroy
      current_cart.checked_items.each(&:compute_price!)
    end

    def compute_amount
      self.original_amount = single_price * number
      self.advance_amount = good.advance_price * number if good
      self.amount = original_amount
    end

    def order_uuid
      order.uuid
    end

    def cart_organ
      organ.name
    end

    def original_quantity
      return unless good
      good.unified_quantity * self.number
    end

    # 批发价和零售价之间的差价，即批发折扣
    def discount_price
      wholesale_price - (retail_price * number)
    end

    def do_compute_promotes(metering_attributes = attributes.slice(*PROMOTE_COLUMNS))
      unavailable_ids = unavailable_promote_goods.map(&:promote_id)

      r = available_promote_goods.includes(:promote).where.not(promote_id: unavailable_ids).map do |promote_good|
        value = metering_attributes[promote_good.promote.metering]
        promote_charge = promote_good.promote.compute_charge(value, **extra)
        next unless promote_charge

        item_promotes.find(&->(i){ i.promote_id == promote_good.promote_id }) || item_promotes.build(promote_good_id: promote_good.id, promote_charge_id: promote_charge.id, value: value)
      end

      r.compact!
      r
    end

    def sum_amount
      _additional_amount = item_promotes.select(&->(o){ o.amount >= 0 }).sum(&->(i){ i.amount.to_d })
      _reduced_amount = item_promotes.select(&->(o){ o.amount < 0 }).sum(&->(i){ i.amount.to_d }) # 促销价格
      {
        additional_amount: _additional_amount,
        reduced_amount: _reduced_amount,
        retail_price: single_price + _additional_amount,
        wholesale_price: original_amount + _additional_amount,
        amount: original_amount + _additional_amount + _reduced_amount  # 最终价格
      }
    end

    def remove_promotes
      if order
        order.compute_promote
        order.save
      elsif current_cart
        current_cart.compute_promote
        current_cart.save
      end
    end

    def add_promotes
      do_compute_promotes
      self.assign_attributes sum_amount
      current_cart.compute_promote if current_cart
    end

    def reset_promotes
      result = do_compute_promotes
      self.assign_attributes sum_amount
      if order
        order.compute_promote
      elsif current_cart
        current_cart.compute_promote
      end

      if persisted?
        result.each(&:save!)
        if order
          order.save!
        elsif current_cart
          current_cart.save!
        end
      end
    end

    def sync_amount_to_current_cart
      return unless current_cart

      current_cart.compute_amount
      logger.debug "\e[33m  Item Object id: #{object_id}"
      current_cart.save!
    end

    def set_not_fresh
      if current_cart_id
        carts.where.not(id: current_cart_id).update_all(fresh: false)
      else
        carts.update_all(fresh: false)
      end
    end

    def sync_ordered_to_current_cart
      return unless current_cart
      if ['ordered'].include?(status) && ['checked', 'trial'].include?(status_previously_was)
        current_cart.with_lock do
          current_cart.item_amount -= amount
          current_cart.save!
        end
      end
    end

    def reset_amount
      self.additional_amount = item_promotes.default_where('amount-gte': 0).sum(:amount)
      self.reduced_amount = item_promotes.default_where('amount-lt': 0).sum(:amount)
      self.amount = original_amount + additional_amount + reduced_amount
      self.valid?
      self.changes
    end

    def reset_amount!(*args)
      self.reset_amount
      self.save(*args)
    end

    def order_work
      return unless good
      case status
      when 'ordered'
        self.item_promotes.update(status: 'ordered')
        self.good.order_done(self)
      when 'trial'
        self.good.order_trial(self)
      when 'deliverable'
        if aim_rent?
          self.good.order_rentable(self)
          self.advance_and_block
        else
          self.good.order_deliverable(self)
        end
      when 'refund'
        self.good.order_refund(self)
      when 'done'
        if aim_rent?
          self.good.order_rented(self)
        end
      else
        logger.debug ''
      end
    end

    def advance_and_block
      lawful_wallet.wallet_advances.find_or_create_by(item_id: id, amount: amount)
      lawful_wallet.wallet_frozens.find_or_create_by(item_id: id, amount: amount)
    end

    def order_pruned!
      good&.order_prune(self)
    end

    def expired?
      expire_at.acts_like?(:time) && Time.current > expire_at
    end

    def clean_when_expired
      ItemCleanJob.set(wait_until: expire_at).perform_later(self)
    end

  end
end
