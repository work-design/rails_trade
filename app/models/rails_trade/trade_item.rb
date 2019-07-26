module RailsTrade::TradeItem
  extend ActiveSupport::Concern
  included do
    attribute :status, :string, default: 'init'
    attribute :myself, :boolean, default: true  # 是否后台协助添加
    attribute :starred, :boolean, default: false  # 收藏
    
    attribute :good_type, :string
    attribute :good_id, :integer

    attribute :number, :integer, default: 1
    attribute :quantity, :decimal, default: 0  # 重量
    attribute :unit, :string  # 单位

    attribute :single_price, :decimal, default: 0  # 一份产品的价格
    attribute :original_price, :decimal, default: 0  # 商品原价，合计份数之后

    attribute :additional_price, :decimal, default: 0  # 附加服务价格汇总
    attribute :reduced_price, :decimal, default: 0  # 已优惠的价格
    
    attribute :retail_price, :decimal, default: 0  # 单个商品零售价(商品原价 + 服务价)
    attribute :wholesale_price, :decimal, default: 0  # 多个商品批发价
    
    attribute :amount, :decimal, default: 0
    attribute :note, :string
    attribute :advance_payment, :decimal, default: 0
    attribute :extra, :json, default: {}

    belongs_to :good, polymorphic: true
    belongs_to :trade, polymorphic: true, inverse_of: :trade_items
    has_many :trade_promotes, -> { includes(:promote) }, inverse_of: :trade_item, dependent: :destroy
    has_many :providers, dependent: :delete_all  # 用于对接供应商

    scope :valid, -> { where(status: 'init', myself: true) }
    scope :starred, -> { where(status: 'init', starred: true) }
    
    enum status: {
      init: 'init',
      checked: 'checked',
      ordered: 'ordered',
      done: 'done',
      canceled: 'canceled'
    }

    before_validation :sync_amount
    after_save :sync_order_amount, if: -> { saved_change_to_amount? }
    after_commit :sync_cart_charges, :total_cart_charges, if: -> { number_changed? }, on: [:create, :update]
  end

  def origin_quantity
    good.unified_quantity * self.number
  end

  # 批发价和零售价之间的差价，即批发折扣
  def discount_price
    wholesale_price - (retail_price * number)
  end
  
  def compute_amount
    self.single_price = good.price
    self.original_price = good.price * number
  
    self.additional_price = trade_promotes.select(&->(ep){ ep.single? && ep.amount >= 0 }).sum(&:amount)
    self.reduced_price = trade_promotes.select(&->(ep){ ep.single? && ep.amount < 0 }).sum(&:amount)  # 促销价格

    self.retail_price = single_price + additional_price
    self.wholesale_price = original_price + additional_price
    
    self.amount = original_price + additional_price + reduced_price  # 最终价格
  end
  
  def sync_amount
    self.advance_payment = self.good.advance_payment if self.advance_payment.zero?
  end

  def sync_order_amount
    trade.compute_amount
    trade.save
  end

  def confirm_ordered!
    self.good.order_done
  end

  def confirm_paid!

  end

  def confirm_part_paid!

  end

  def confirm_refund!

  end

  def compute_promote
    promote_ids.each do |promote_id|
      self.trade_promotes.build(promote_id: promote_id)
    end
  end

  def compute_charge(promote_good_ids: [], promote_buyer_ids: [])
    all_ids = good.valid_promote_good_ids
    all_ids -= buyer_promotes.pluck(:promote_id)
  
    compute_charges_with_buyer(promote_buyer_ids)
    compute_charges_with_good(promote_good_ids)
  end

  def compute_promote_with_buyer(promote_buyer_ids = [], **extra)
    promote_buyers = PromoteBuyer.where(id: promote_buyer_ids)
  
    promote_buyers.each do |promote_buyer|
      value = metering_attributes.fetch(promote_buyer.promote.metering)
      promote_charge = promote_buyer.promote.compute_charge(value, **extra)
      self.trade_promotes.build(promote_charge_id: promote_charge.id, promote_buyer_id: promote_buyer.id, promote_good_id: promote_buyer.promote_good_id)
    end
  end

  def compute_charge_with_good(promote_good_ids, **extra)
    promote_goods = PromoteGood.find promote_good_ids
    promote_goods.map do |promote_good|
      value = metering_attributes.fetch(promote_good.promote.metering)
      promote_charge = promote_good.promote.compute_charge(value, **extra)
      self.trade_promotes.build(promote_charge_id: promote_charge.id, promote_good_id: promote_good.id)
    end
  end
  
  def metering_attributes
    attributes.slice 'quantity', 'amount', 'number'
  end
  
  class_methods do
    
    def good_types
      CartItem.select(:good_type).distinct.pluck(:good_type)
    end
    
  end

end
