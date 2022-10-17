module Trade
  module Model::Item
    PROMOTE_COLUMNS = ['original_amount', 'number', 'weight', 'volume', 'duration']
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :good_name, :string
      attribute :number, :integer, default: 1, comment: '数量'
      attribute :done_number, :integer, default: 0, comment: '已达成交易数量'
      attribute :rest_number, :integer
      attribute :weight, :integer, default: 1, comment: '重量'
      attribute :duration, :integer, default: 0, comment: '占用时长'
      attribute :volume, :integer, default: 0, comment: '体积'
      attribute :vip_code, :string
      attribute :single_price, :decimal, default: 0, comment: '一份产品的价格'
      attribute :retail_price, :decimal, default: 0, comment: '单个商品零售价(商品原价 + 服务价)'
      attribute :wholesale_price, :decimal, default: 0, comment: '多个商品批发价'
      attribute :original_amount, :decimal, default: 0, comment: '合计份数之后的价格，商品原价'
      attribute :additional_amount, :decimal, default: 0, comment: '附加服务价格汇总'
      attribute :reduced_amount, :decimal, default: 0, comment: '已优惠的价格'
      attribute :amount, :decimal
      attribute :advance_amount, :decimal, default: 0
      attribute :note, :string
      attribute :extra, :json, default: {}
      attribute :produce_on, :date, comment: '对接生产管理'
      attribute :expire_at, :datetime
      attribute :fetch_oneself, :boolean, default: false, comment: '自取'
      attribute :fetch_start_at, :datetime
      attribute :fetch_finish_at, :datetime
      attribute :organ_ancestor_ids, :json, default: []
      attribute :rent_start_at, :datetime
      attribute :rent_finish_at, :datetime
      attribute :rent_estimate_finish_at, :datetime
      attribute :estimate_amount, :json, default: {}

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered',
        trial: 'trial',
        deliverable: 'deliverable',
        part_paid: 'part_paid',
        refund: 'refund',
        packaged: 'packaged',
        done: 'done',
        canceled: 'canceled',
        expired: 'expired'
      }, _default: 'checked', _prefix: true

      enum delivery: {
        init: 'init',
        partially: 'partially',
        all: 'all'
      }, _default: 'init', _prefix: true

      enum aim: {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, _default: 'use', _prefix: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :station, class_name: 'Ship::Station', optional: true
      belongs_to :client, class_name: 'Profiled::Profile', optional: true

      belongs_to :from_address, class_name: 'Profiled::Address', optional: true
      belongs_to :from_station, class_name: 'Ship::Station', optional: true

      belongs_to :agent, class_name: 'Org::Member', optional: true

      has_one :device, class_name: 'JiaBo::Device', foreign_key: :organ_id, primary_key: :organ_id

      if defined?(RailsFactory)
      belongs_to :scene, class_name: 'Factory::Scene', optional: true
      belongs_to :produce_plan, ->(o){ where(organ_id: o.organ_id, produce_on: o.produce_on) }, class_name: 'Factory::ProducePlan', foreign_key: :scene_id, primary_key: :scene_id, optional: true  # 产品对应批次号
      belongs_to :production_plan, ->(o){ where(produce_on: o.produce_on, scene_id: o.scene_id) }, class_name: 'Factory::ProductionPlan', foreign_key: :good_id, primary_key: :production_id, counter_cache: :trade_items_count, optional: true
      end

      belongs_to :good, polymorphic: true, optional: true
      belongs_to :current_cart, class_name: 'Cart', optional: true  # 下单时的购物车
      belongs_to :order, inverse_of: :items, counter_cache: true, optional: true

      has_many :carts, ->(o) { where(organ_id: [o.organ_id, nil], member_id: [o.member_id, nil], good_type: [o.good_type, nil], aim: [o.aim, nil]) }, primary_key: :user_id, foreign_key: :user_id
      has_many :organ_carts, ->(o) { where(member_id: nil, user_id: nil, organ_id: [o.organ_id, nil], good_type: [o.good_type, nil], aim: [o.aim, nil]) }, class_name: 'Cart', primary_key: :member_organ_id, foreign_key: :member_organ_id
      has_many :cards, ->(o) { includes(:card_template).where(o.filter_hash) }, foreign_key: :user_id, primary_key: :user_id
      has_many :wallets, ->(o) { includes(:wallet_template).where(o.filter_hash) }, foreign_key: :user_id, primary_key: :user_id
      has_many :item_promotes, inverse_of: :item, dependent: :destroy_async
      has_many :payment_orders, primary_key: :order_id, foreign_key: :order_id

      has_many :unavailable_promote_goods, ->(o) { unavailable.where(organ_id: o.organ_ancestor_ids, good_id: [o.good_id, nil], aim: o.aim) }, class_name: 'PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :available_promote_goods, ->(o) { effective.where(organ_id: o.organ_ancestor_ids, good_id: [o.good_id, nil], user_id: [o.user_id, nil], member_id: [o.member_id, nil], aim: o.aim) }, class_name: 'PromoteGood', foreign_key: :good_type, primary_key: :good_type

      has_one :rent_promote_good, ->(o) { rent.available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_one :rent_promote, -> { where(metering: 'duration') }, class_name: 'Trade::Promote', through: :rent_promote_good, source: :promote

      has_one_attached :image

      scope :carting, -> { where(status: ['init', 'checked', 'trial', 'expired']) }
      scope :checked, -> { where(status: ['checked', 'trial']) }
      scope :deliverable, -> { where(status: ['deliverable', 'packaged']) }
      scope :packable, -> { where(status: ['paid']) }
      scope :packaged, -> { where(status: ['packaged', 'done']) }

      after_initialize :init_uuid, if: :new_record?
      before_validation :sync_from_produce_plan, if: -> { respond_to?(:produce_plan) && produce_plan }
      before_validation :sync_from_current_cart, if: -> { current_cart && current_cart_id_changed? }
      before_validation :sync_from_good, if: -> { good_id.present? && good_id_changed? }
      before_validation :sync_from_member, if: -> { member_id.present? && member_id_changed? }
      before_validation :compute_price, if: -> { good_id_changed? }
      before_validation :sync_from_organ, if: -> { organ_id.present? && organ_id_changed? }
      before_validation :compute_amount, if: -> { (changes.keys & ['number', 'single_price']).present? }
      before_validation :compute_rest_number, if: -> { (changes.keys & ['number', 'done_number']).present? }
      before_save :sync_from_order, if: -> { order_id.present? && order_id_changed? }
      before_save :compute_duration, if: -> { (rent_finish_at.present? || rent_estimate_finish_at.present?) && (['rent_finish_at', 'rent_estimate_finish_at'] & changes.keys).present? }
      before_save :compute_promotes, if: -> { (changes.keys & PROMOTE_COLUMNS).present? }
      after_create :clean_when_expired, if: -> { expire_at.present? }
      after_save :sync_promote_to_order!, if: -> { order_id.present? && (saved_changes.keys & PROMOTE_COLUMNS).present? }
      after_save :sync_amount_to_current_cart, if: -> { current_cart_id.present? && (saved_changes.keys & ['amount', 'status']).present? && ['init', 'checked', 'trial'].include?(status) }
      after_destroy :order_pruned!
      after_destroy :sync_amount_to_current_cart, if: -> { current_cart_id.present? && ['checked', 'trial'].include?(status) }
      after_save_commit :sync_ordered_to_current_cart, if: -> { current_cart_id.present? && (saved_change_to_status? && status == 'ordered') }
      after_save_commit :order_work_later, if: -> { saved_change_to_status? && ['ordered', 'trail', 'deliverable', 'done', 'refund'].include?(status) }
      after_save_commit :compute_later, if: -> { aim_rent? && saved_change_to_status? && ['ordered'].include?(status) }

      acts_as_notify(
        :default,
        only: [:good_name, :number, :amount, :note],
        methods: [:order_uuid, :cart_organ]
      )
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
      self.uuid = UidHelper.nsec_uuid('ITEM')
    end

    def sync_from_organ
      return unless organ
      self.organ_ancestor_ids = organ.self_and_ancestor_ids
    end

    def sync_from_good
      return unless good
      self.good_name = good.name
      self.organ_id = (good.respond_to?(:organ_id) && good.organ_id) || current_cart&.organ_id
      self.produce_on = good.produce_on if good.respond_to? :produce_on
    end

    def sync_from_current_cart
      self.aim = current_cart.aim
      self.good_type ||= current_cart.good_type
    end

    def sync_from_member
      return unless member
      self.user = member.user
      self.member_organ_id = member.organ_id  # 数据冗余，方便订单搜索和筛选
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

    def sync_from_produce_plan
      self.produce_on = produce_plan.produce_on
      self.expire_at = produce_plan.book_finish_at
    end

    def wallet_amount
      good.wallet_price.transform_values(&->(v){ { rate: Rational(single_price.to_s, v), amount: v.to_d * number } })
    end

    def compute_single_price
      return if self.single_price > 0 || aim_rent?
      min = good.card_price.slice(*cards.map(&->(i){ i.card_template.code })).min
      if min.present?
        self.vip_code = min[0]
        self.single_price = min[1]
      else
        self.vip_code = nil
        self.single_price = good.price
      end
    end

    def compute_price
      return unless good
      compute_single_price
      self.advance_amount = good.advance_price
    end

    def compute_price!
      compute_price
      save
    end

    def compute_amount
      self.original_amount = single_price * number
      self.amount = original_amount
    end

    def order_uuid
      order.uuid
    end

    def cart_organ
      organ.name
    end

    def original_quantity
      good.unified_quantity * self.number
    end

    # 批发价和零售价之间的差价，即批发折扣
    def discount_price
      wholesale_price - (retail_price * number)
    end

    def compute_rest_number
      self.rest_number = self.number - self.done_number
    end

    def do_compute_promotes
      unavailable_ids = unavailable_promote_goods.map(&:promote_id)

      available_promote_goods.where.not(promote_id: unavailable_ids).map do |promote_good|
        item_promote = item_promotes.find(&->(i){ i.promote_id == promote_good.promote_id }) || item_promotes.build(promote_id: promote_good.promote_id)
        item_promote.value = metering_attributes[promote_good.promote.metering]
        item_promote.promote_good = promote_good
        item_promote.save
        item_promote
      end

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

    def compute_promotes
      self.assign_attributes do_compute_promotes
      self.changes
    end

    def sync_amount_to_current_cart
      return unless current_cart
      if (destroyed? && ['checked', 'trial'].include?(status)) || (['init'].include?(status) && ['checked', 'trial'].include?(status_previously_was))
        changed_amount = -amount
      elsif ['checked', 'trial'].include?(status) && ['init', nil].include?(status_previously_was)
        changed_amount = amount
      elsif ['checked', 'trial'].include?(status) && amount_previously_was
        changed_amount = amount - amount_previously_was.to_d
      else
        return
      end

      current_cart.item_amount += changed_amount
      logger.debug "\e[33m  Item amount: #{current_cart.item_amount}, Summed amount: #{current_cart.checked_items.sum(&->(i){ i.amount.to_d })}, Cart id: #{current_cart.id})  \e[0m"
      current_cart.save!
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

    def sync_promote_to_order!
      return unless order
      order.compute_promote
      order.save!
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

    def metering_attributes
      attributes.slice *PROMOTE_COLUMNS
    end

    def to_notice
      to_notification(
        user: user,
        title: '您的订单已准备好',
        body: '您的订单将按时到达配送点',
        link: Rails.application.routes.url_for(controller: 'trade/board/orders', action: 'show', id: order_id),
        verbose: true,
        organ_id: organ_id
      )
    end

    def order_work_later
      ItemJob.perform_later(self)
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
          self.update(rent_start_at: Time.current)
          self.good.order_rentable(self)
        else
          self.good.order_deliverable(self)
        end
      when 'part_paid'
        self.good.order_part_paid(self)
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

    def order_pruned!
      self.good.order_prune(self) if good
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
      ItemCleanJob.set(wait_until: expire_at).perform_later(self)
    end

    def compute_continue(now = Time.current)
      compute_later(now + 1.hour)
    end

    def compute_later(now = Time.current)
      wait = now.change(min: rent_start_at.min, sec: rent_start_at.sec)
      wait += 1.hour if wait <= now

      ItemRentJob.set(wait_until: wait).perform_later(self, wait)
    end

    def compute_duration(now = Time.current)
      return unless order
      if rent_finish_at
        r = rent_finish_at - rent_start_at
      else
        r = now - rent_start_at
      end
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      self.duration = x[rent_promote.unit_code].ceil if rent_promote
    end

    def compute_estimate_duration
      return unless estimate_finish_at
      r = rent_estimate_finish_at - rent_start_at
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      self.duration = x[rent_promote.unit_code].ceil if rent_promote
      self.estimate_amount = do_compute_promotes
    end

  end
end
