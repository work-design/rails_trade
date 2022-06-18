module Trade
  module Model::TradeItem
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :good_name, :string
      attribute :number, :integer, default: 1, comment: '数量'
      attribute :weight, :integer, default: 0, comment: '重量'
      attribute :duration, :integer, default: 0, comment: '占用时长'
      attribute :volume, :integer, default: 0, comment: '体积'
      attribute :amount, :decimal, default: 0
      attribute :vip_code, :string
      attribute :single_price, :decimal, default: 0, comment: '一份产品的价格'
      attribute :retail_price, :decimal, default: 0, comment: '单个商品零售价(商品原价 + 服务价)'
      attribute :original_amount, :decimal, default: 0, comment: '合计份数之后的价格，商品原价'
      attribute :additional_amount, :decimal, default: 0, comment: '附加服务价格汇总'
      attribute :reduced_amount, :decimal, default: 0, comment: '已优惠的价格'
      attribute :wholesale_price, :decimal, default: 0, comment: '多个商品批发价'
      attribute :note, :string
      attribute :advance_amount, :decimal, default: 0
      attribute :extra, :json, default: {}
      attribute :produce_on, :date, comment: '对接生产管理'
      attribute :expire_at, :datetime
      attribute :fetch_oneself, :boolean, default: false, comment: '自取'
      attribute :fetch_start_at, :datetime
      attribute :fetch_finish_at, :datetime

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered',
        trial: 'trial',
        paid: 'paid',
        part_paid: 'part_paid',
        pay_later: 'pay_later',
        packaged: 'packaged',
        done: 'done',
        canceled: 'canceled',
        expired: 'expired'
      }, _default: 'checked', _prefix: true

      enum aim: {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, _default: 'use', _prefix: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User'
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :agent, class_name: 'Org::Member', optional: true
      has_one :device, class_name: 'JiaBo::Device', foreign_key: :organ_id, primary_key: :organ_id

      if defined?(RailsFactory)
      belongs_to :scene, class_name: 'Factory::Scene', optional: true
      belongs_to :produce_plan, ->(o){ where(organ_id: o.organ_id, produce_on: o.produce_on) }, class_name: 'Factory::ProducePlan', foreign_key: :scene_id, primary_key: :scene_id, optional: true  # 产品对应批次号
      belongs_to :production_plan, ->(o){ where(produce_on: o.produce_on, scene_id: o.scene_id) }, class_name: 'Factory::ProductionPlan', foreign_key: :good_id, primary_key: :production_id, counter_cache: true, optional: true
      end

      belongs_to :good, polymorphic: true
      belongs_to :current_cart, class_name: 'Cart', optional: true  # 下单时的购物车
      belongs_to :order, inverse_of: :trade_items, counter_cache: true, optional: true

      has_many :carts, ->(o){ where(organ_id: [o.organ_id, nil], member_id: [o.member_id, nil], good_type: [o.good_type, nil], aim: [o.aim, nil]) }, primary_key: :user_id, foreign_key: :user_id
      has_many :organ_carts, ->(o){ where(member_id: nil, user_id: nil, organ_id: [o.organ_id, nil], good_type: [o.good_type, nil], aim: [o.aim, nil]) }, class_name: 'Cart', primary_key: :member_organ_id, foreign_key: :member_organ_id
      has_many :cards, ->(o){ includes(:card_template).where(organ_id: o.organ_id, member_id: o.member_id) }, foreign_key: :user_id, primary_key: :user_id
      has_many :item_promotes, inverse_of: :trade_item, autosave: true, dependent: :destroy_async

      has_many :unavailable_promote_goods, ->(o) { unavailable.where(organ_id: o.organ_id, good_id: [o.good_id, nil], aim: o.aim) }, class_name: 'PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :available_promote_goods, ->(o) { effective.where(organ_id: o.organ_id, good_id: [o.good_id, nil], user_id: [o.user_id, nil], member_id: [o.member_id, nil], aim: o.aim) }, class_name: 'PromoteGood', foreign_key: :good_type, primary_key: :good_type

      scope :carting, ->{ where(status: ['init', 'checked', 'trial', 'expired']) }
      scope :checked, ->{ where(status: ['checked', 'trial']) }
      scope :deliverable, ->{ where(status: ['paid', 'packaged']) }
      scope :packable, ->{ where(status: ['paid']) }
      scope :packaged, ->{ where(status: ['packaged', 'done']) }

      after_initialize :init_uuid, if: :new_record?
      before_validation :sync_from_produce_plan, if: -> { respond_to?(:produce_plan) && produce_plan }
      before_validation :sync_from_good, if: -> { good && good_id_changed? }
      before_validation :sync_from_member, if: -> { member && member_id_changed? }
      before_validation :compute_price, if: -> { new_record? || good_id_changed? }
      before_validation :sync_user_from_order, if: -> { order && user_id.blank? }
      before_save :recompute_amount, if: -> { (changes.keys & ['number']).present? }
      before_save :sync_from_order, if: -> { order.present? && order_id_changed? }
      before_save :sum_amount, if: -> { original_amount_changed? }
      after_create :clean_when_expired, if: -> { expire_at.present? }
      after_save :sync_amount_to_current_cart, if: -> { (saved_changes.keys & ['amount', 'status']).present? && ['init', 'checked', 'trial'].include?(status) }
      after_save :order_ordered!, if: -> { saved_change_to_status? && ['ordered'].include?(status) }
      after_save :order_trial!, if: -> { saved_change_to_status? && ['trial'].include?(status) }
      after_save :order_paid!, if: -> { saved_change_to_status? && ['paid'].include?(status) }
      after_save :order_part_paid!, if: -> { saved_change_to_status? && ['part_paid'].include?(status) }
      after_save :order_pay_later!, if: -> { saved_change_to_status? && ['pay_later'].include?(status) }
      after_save :print_later, if: -> { saved_change_to_status? && ['part_paid', 'paid'].include?(status) && (respond_to?(:produce_plan) && produce_plan.blank?) }
      after_destroy :order_pruned!
      after_destroy :sync_amount_to_all_carts  # 正常情况下，order_id 存在的情况下，不会触发 trade_item 的删除

      acts_as_notify(:default, only: [:good_name, :number, :amount, :note], methods: [:order_uuid, :cart_organ])
    end

    def init_uuid
      self.uuid = UidHelper.nsec_uuid('ITEM')
      self
    end

    def sync_from_good
      self.good_name = good.name
      self.organ_id = good.organ_id if good.respond_to? :organ_id
      self.produce_on = good.produce_on if good.respond_to? :produce_on
    end

    def sync_from_member
      self.user = member.user
      self.member_organ_id = member.organ_id  # 数据冗余，方便订单搜索和筛选
    end

    def sync_from_produce_plan
      self.produce_on = produce_plan.produce_on
      self.expire_at = produce_plan.book_finish_at
    end

    def compute_price
      min = good.vip_price.slice(*cards.map(&->(i){ i.card_template.code })).min
      if min.present?
        self.vip_code = min[0]
        self.single_price = min[1]
      else
        self.vip_code = nil
        self.single_price = good.price unless self.single_price > 0
      end
      self.original_amount = self.single_price * self.number
      self.amount = original_amount
      self.advance_amount = good.advance_price
    end

    def compute_price!
      compute_price
      save
    end

    def order_uuid
      order.uuid
    end

    def cart_organ
      organ.name
    end

    def weight_str
      if weight > 0
        "#{weight} #{unit}"
      end
    end

    def original_quantity
      good.unified_quantity * self.number
    end

    # 批发价和零售价之间的差价，即批发折扣
    def discount_price
      wholesale_price - (retail_price * number)
    end

    def recompute_amount
      self.original_amount = single_price * number
    end

    def available_promotes
      promotes = {}
      unavailable_ids = unavailable_promote_goods.pluck(:promote_id)

      available_promote_goods.where.not(promote_id: unavailable_ids).each do |promote_good|
        promotes.merge! promote_good.promote_id => {
          promote_good: promote_good,
          trade_item: self
        }
      end

      promotes
    end

    def sum_amount
      self.additional_amount = item_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
      self.reduced_amount = item_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)  # 促销价格

      self.retail_price = single_price + additional_amount
      self.wholesale_price = original_amount + additional_amount
      self.amount = original_amount + additional_amount + reduced_amount  # 最终价格
      self.changes
    end

    def sync_amount_to_current_cart
      if (destroyed? && ['checked', 'trial'].include?(status)) || (status_init? && ['checked'].include?(status_previously_was) )
        changed_amount = -amount
      elsif ['checked', 'trial'].include?(status) && ['init', nil].include?(status_previously_was)
        changed_amount = amount
      elsif ['checked', 'trial'].include?(status) && amount_previously_was
        changed_amount = amount - amount_previously_was.to_d
      else
        return
      end

      current_cart.item_amount += changed_amount
      logger.debug "\e[33m  Item amount: #{current_cart.item_amount}, Summed amount: #{current_cart.checked_trade_items.sum(&:amount)}, Cart id: #{current_cart.id})  \e[0m"
      current_cart.save!
    end

    def sync_amount_to_all_carts
      carts
      organ_carts
    end

    def reset_carts
      carts.each do |cart|
        cart.reset_amount
        cart.save
      end
      organ_carts.each do |cart|
        cart.reset_amount
        cart.save
      end
    end

    # 理论上共计 24 个购物车
    def check_carts
      # 理论上是 2 的 4 次方 16 个
      # organ_id 为 nil，则为平台级订单
      [organ_id, nil].each do |org_id|
        [member_id, nil].each do |mem_id|
          [aim, nil].each do |_aim|
            [good_type, nil].each do |_type|
              r = { 'organ_id' => org_id, 'member_id' => mem_id, 'aim' => _aim, 'good_type' => _type }
              carts.find(&->(i){ i.attributes.slice(*r.keys) == r }) || carts.build(r)
            end
          end
        end
      end

      # 理论上是 2 的 3 次方 8 个
      # 非用户级别的购物车
      if member_organ
        [organ_id, nil].each do |org_id|
          [aim, nil].each do |_aim|
            [good_type, nil].each do |_type|
              r = { 'member_id' => nil, 'user_id' => nil, 'organ_id' => org_id, 'aim' => _aim, 'good_type' => _type }
              organ_carts.find(&->(i){ i.attributes.slice(*r.keys) == r }) || organ_carts.build(r)
            end
          end
        end
      end

      save
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

    def sync_from_order
      self.address_id = order.address_id
    end

    def sync_user_from_order
      self.user = order.user
    end

    def metering_attributes
      attributes.slice 'original_amount', 'number', 'weight', 'volume', 'duration'
    end

    def to_notice
      to_notification(
        user: user,
        title: '您的订单已准备好',
        body: '您的订单将按时到达配送点',
        link: Rails.application.routes.url_for(controller: 'trade/my/orders', action: 'show', id: order_id),
        verbose: true,
        organ_id: organ_id
      )
    end

    def order_ordered!
      self.item_promotes.update(status: 'ordered')
      self.good.order_done
    end

    def order_trial!
      self.good.order_trial(self)
    end

    def order_paid!
      self.good.order_paid(self)
    end

    def order_pruned!
      self.good.order_prune(self)
    end

    def order_part_paid!
      self.good.order_part_paid(self)
    end

    def order_pay_later!
      self.good.order_pay_later(self)
    end

    def order_refund!
      self.good.order_refund(self)
    end

    def fetch_include?(start_time, finish_time)
      return nil if fetch_start_at.blank?
      start = fetch_start_at.to_fs(:time)
      finish = fetch_finish_at.to_fs(:time)

      start <= start_time && finish >= finish_time
    end

    def expired?
      expire_at.acts_like?(:time) && Time.current > expire_at
    end

    def clean_when_expired
      TradeItemCleanJob.set(wait_until: expire_at).perform_later(self)
    end

    def print_later
    end

    def print
    end

  end
end
