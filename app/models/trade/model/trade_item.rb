module Trade
  module Model::TradeItem
    extend ActiveSupport::Concern

    included do
      attribute :status, :string
      attribute :myself, :boolean, default: true, comment: '是否后台协助添加'
      attribute :starred, :boolean, default: false, comment: '收藏'
      attribute :good_name, :string
      attribute :number, :integer, default: 1
      attribute :weight, :decimal, default: 0, comment: '重量'
      attribute :unit, :string, comment: '单位'
      attribute :single_price, :decimal, default: 0, comment: '一份产品的价格'
      attribute :retail_price, :decimal, default: 0, comment: '单个商品零售价(商品原价 + 服务价)'
      attribute :original_amount, :decimal, default: 0, comment: '合计份数之后的价格，商品原价'
      attribute :additional_amount, :decimal, default: 0, comment: '附加服务价格汇总'
      attribute :reduced_amount, :decimal, default: 0, comment: '已优惠的价格'
      attribute :wholesale_price, :decimal, default: 0, comment: '多个商品批发价'
      attribute :amount, :decimal, default: 0
      attribute :note, :string
      attribute :advance_amount, :decimal, default: 0
      attribute :extra, :json, default: {}
      attribute :produce_on, :date, comment: '对接生产管理'
      attribute :expire_at, :datetime

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User'
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :agent, class_name: 'Org::Member', optional: true
      has_one :device, class_name: 'JiaBo::Device', foreign_key: :organ_id, primary_key: :organ_id

      #has_many :organs 用于对接供应商

      belongs_to :scene, class_name: 'Factory::Scene', optional: true
      belongs_to :produce_plan, ->(o) { where(organ_id: o.organ_id, produce_on: o.produce_on) }, class_name: 'Factory::ProducePlan', foreign_key: :scene_id, primary_key: :scene_id, optional: true  # 产品对应批次号
      belongs_to :production_plan, ->(o) { where(produce_on: o.produce_on, scene_id: o.scene_id) }, class_name: 'Factory::ProductionPlan', foreign_key: :good_id, primary_key: :production_id, counter_cache: true, optional: true

      belongs_to :good, polymorphic: true
      belongs_to :cart, ->(o){ where(organ_id: o.organ_id, member_id: o.member_id) }, inverse_of: :trade_items, foreign_key: :user_id, primary_key: :user_id, optional: true
      belongs_to :order, inverse_of: :trade_items, counter_cache: true, optional: true
      has_many :trade_promotes, inverse_of: :trade_item, autosave: true, dependent: :destroy_async

      scope :valid, -> { where(status: 'init', myself: true) }
      scope :starred, -> { where(status: 'init', starred: true) }
      scope :carting, -> { where(status: ['init', 'checked']) }
      default_scope -> { order(id: :asc) }

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered',
        paid: 'paid',
        packaged: 'packaged',
        done: 'done',
        canceled: 'canceled'
      }, _default: 'init'

      acts_as_notify(
        :default,
        only: [:good_name, :number, :amount, :note],
        methods: [:order_uuid, :cart_organ]
      )

      after_initialize if: :new_record? do
        self.good_name = good&.name
        self.organ_id ||= good&.organ_id
        self.produce_on = good.produce_on if good.respond_to? :produce_on
        compute_price
        if produce_plan
          self.produce_on = produce_plan.produce_on
          self.expire_at = produce_plan.book_finish_at
        end
        if member
          self.user_id = member.user&.id
          self.member_organ_id = member.organ_id  # 数据冗余，方便订单搜索和筛选
        end
        self.original_amount = single_price * self.number
        self.amount = original_amount
      end
      before_save :recompute_amount, if: -> { (changes.keys & ['number']).present? }
      before_save :compute_promote, if: -> { original_amount_changed? }
      after_save :sync_changed_amount, if: -> {
        (saved_changes.keys & ['amount', 'status']).present? && ['init', 'checked'].include?(status)
      }
      after_save :sync_after_ordered, if: -> { order && saved_change_to_order_id? }
      after_destroy :sync_changed_amount  # 正常情况下，order_id 存在的情况下，不会出发 trade_item 的删除
      after_create_commit :clean_when_expired, if: -> { expire_at.present? }
      after_save_commit :print_later, if: -> { saved_change_to_status? && ['paid'].include?(status) && produce_plan.blank? }
    end

    def compute_price
      # todo
      if cart&.card
        self.single_price = good.vip_price.fetch(cart.card.card_template.code, good.price)
      else
        self.single_price = good&.price
      end
      self.advance_amount = good&.advance_price
    end

    def order_uuid
      order.uuid
    end

    def cart_organ
      cart.organ.name
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

    def sync_after_ordered
      cart.compute_amount
      cart.save
    end

    def available_promotes
      single_promotes = {}
      total_promotes = {}

      good.valid_promote_goods.each do |promote_good|
        if promote_good.promote.single?
          single_promotes.merge! promote_good.promote_id => { promote: promote_good.promote, promote_good_id: promote_good.id }
        else
          total_promotes.merge! promote_good.promote_id => { promote: promote_good.promote, promote_good_id: promote_good.id }
        end
      end
      cart.available_promote_carts.each do |promote_cart|
        if promote_cart.promote.single?
          single_promotes.merge! promote_cart.promote_id => { promote: promote_cart.promote, promote_good_id: promote_cart.promote_good_id, promote_cart_id: promote_cart.id }
        else
          total_promotes.merge! promote_cart.promote_id => { promote: promote_cart.promote, promote_good_id: promote_cart.promote_good_id, promote_cart_id: promote_cart.id }
        end
      end if cart

      [single_promotes, total_promotes]
    end

    def compute_promote(**extra)
      single_promotes = available_promotes[0]

      single_promotes.each do |_, promote_hash|
        value = metering_attributes.fetch(promote_hash[:promote].metering)
        promote_charge = promote_hash[:promote].compute_charge(value, **extra)
        next unless promote_charge

        tp = trade_promotes.find(&->(i){ i.promote_good_id == promote_hash[:promote_good_id] && i.promote_cart_id == promote_hash[:promote_cart_id] }) || trade_promotes.build(promote_good_id: promote_hash[:promote_good_id], promote_cart_id: promote_hash[:promote_cart_id])
        tp.promote_charge_id = promote_charge.id
        tp.compute_amount
      end

      sum_amount
    end

    def sum_amount
      self.additional_amount = trade_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
      self.reduced_amount = trade_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)  # 促销价格

      self.retail_price = single_price + additional_amount
      self.wholesale_price = original_amount + additional_amount

      self.amount = original_amount + additional_amount + reduced_amount  # 最终价格
      self.changes
    end

    def sync_changed_amount
      if (destroyed? && checked?) || (init? && status_previously_was == 'checked')
        changed_amount = -amount
      elsif checked? && ['init', nil].include?(status_previously_was)
        changed_amount = amount
      elsif checked? && amount_previously_was
        changed_amount = amount - amount_previously_was.to_d
      else
        return
      end

      cart.item_amount += changed_amount
      logger.debug "\e[33m  Item amount: #{cart.item_amount}, Summed amount: #{cart.checked_trade_items.sum(&:amount)}, Cart id: #{cart.id})  \e[0m"
      cart.save!
    end

    def reset_amount
      self.additional_amount = trade_promotes.default_where('amount-gte': 0).sum(:amount)
      self.reduced_amount = trade_promotes.default_where('amount-lt': 0).sum(:amount)
      self.amount = original_amount + additional_amount + reduced_amount
      self.valid?
      self.changes
    end

    def reset_amount!(*args)
      self.reset_amount
      self.save(*args)
    end

    def valid_promote_buyers(buyer)
      ids = (available_promote_ids & buyer.all_promote_ids) - buyer.promote_buyers.pluck(:promote_id)
      Promote.where(id: ids)
    end

    def metering_attributes
      attributes.slice 'quantity', 'original_amount', 'number'
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

    def confirm_ordered!
      self.good.order_done
    end

    def confirm_paid!
      self.update status: 'paid'
      self.good.order_paid(self)
    end

    def confirm_part_paid!
    end

    def confirm_refund!
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
