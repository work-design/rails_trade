module RailsTrade::TradeItem
  extend ActiveSupport::Concern

  included do
    attribute :status, :string, default: 'checked'
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

    belongs_to :good, polymorphic: true
    belongs_to :user
    belongs_to :total_cart, foreign_key: :user_id, primary_key: :user_id
    belongs_to :cart, counter_cache: true
    belongs_to :order, inverse_of: :trade_items, counter_cache: true, optional: true
    belongs_to :address, optional: true
    belongs_to :produce_plan, optional: true  # 产品对应批次号
    has_many :trade_promotes, -> { includes(:promote) }, inverse_of: :trade_item, autosave: true, dependent: :destroy
    #has_many :organs 用于对接供应商

    scope :valid, -> { where(status: 'init', myself: true) }
    scope :starred, -> { where(status: 'init', starred: true) }
    default_scope -> { order(id: :asc) }

    enum status: {
      init: 'init',
      checked: 'checked',
      ordered: 'ordered',
      paid: 'paid',
      packaged: 'packaged',
      done: 'done',
      canceled: 'canceled'
    }

    after_initialize if: :new_record? do
      if good
        self.good_name = good.name
        self.single_price = good.price
        self.advance_amount = good.advance_price
        self.produce_plan_id = good.product_plan&.produce_plan_id if good.respond_to? :product_plan_id
      end
      if cart
        self.user_id = cart.user_id
        self.member_id = cart.member_id if cart.respond_to? :member_id
      end
      self.original_amount = single_price * number
      self.amount = original_amount
    end
    before_save :recompute_amount, if: -> { (changes.keys & ['number']).present? }
    before_save :compute_promote, if: -> { original_amount_changed? }
    after_save :sync_changed_amount, if: -> {
      (saved_changes.keys & ['original_amount', 'additional_amount', 'reduced_amount']).present? ||
        (saved_change_to_status? && status == 'checked')
    }
    after_destroy_commit :sync_changed_amount
    after_commit :sync_cart_charges, :total_cart_charges, if: -> { number_changed? }, on: [:create, :update]
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
    self.amount = original_amount + additional_amount + reduced_amount
  end

  def check
    self.order = cart.checked_order
    self.status = 'checked'
    self.save
    self
  end

  def uncheck
    self.order = nil
    self.status = 'init'
    self.save
    self
  end

  def compute_promote
    good.valid_promote_goods.map do |promote_good|
      value = metering_attributes.fetch(promote_good.promote.metering)
      promote_charge = promote_good.promote.compute_charge(value, **extra)
      next unless promote_charge
      if promote_good.promote.single?
        tp = self.trade_promotes.find(&->(i){ i.promote_good_id == promote_good.id }) || trade_promotes.build(promote_good_id: promote_good.id)
      else
        tp = order.trade_promotes.find(&->(i){ i.promote_good_id == promote_good.id }) || order.trade_promotes.build(promote_good_id: promote_good.id)
      end
      tp.promote_charge_id = promote_charge.id
      tp.compute_amount
    end

    order.promote_carts.each do |promote_cart|
      value = metering_attributes.fetch(promote_cart.promote.metering)
      promote_charge = promote_cart.promote.compute_charge(value, **extra)
      next unless promote_charge
      if promote_good.promote.single?
        tp = self.trade_promotes.find_or_initialize_by(promote_cart_id: promote_cart.id, promote_good_id: promote_cart.promote_good_id)
      else
        tp = trade.trade_promotes.find_or_initialize_by(promote_cart_id: promote_cart.id, promote_good_id: promote_cart.promote_good_id)
      end
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
    self
  end

  def sync_changed_amount
    order.reload
    if destroyed?
      changed_amount = -amount
    else
      changed_amount = amount - amount_before_last_save.to_d
    end
    order.item_amount += changed_amount
    order.amount += changed_amount
    if checked?
      total_cart.amount += changed_amount
      total_cart.item_amount += changed_amount
    end
    computed_amount = order.compute_amount
    if order.amount == computed_amount
      order.save!
      total_cart.save! if checked?
    else
      order.errors.add :amount, "#{order.amount} not equal #{computed_amount}"
      logger.error "#{self.class.name}/#{order.class.name}: #{order.error_text}"
      raise ActiveRecord::RecordInvalid.new(order)
    end
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

  def confirm_ordered!
    self.good.order_done
  end

  def confirm_paid!
    self.update status: 'paid'
  end

  def confirm_part_paid!
  end

  def confirm_refund!
  end

end
