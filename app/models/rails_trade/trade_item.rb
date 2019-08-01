module RailsTrade::TradeItem
  extend ActiveSupport::Concern
  included do
    attribute :status, :string, default: 'init'
    attribute :myself, :boolean, default: true  # 是否后台协助添加
    attribute :starred, :boolean, default: false  # 收藏
    
    attribute :good_type, :string
    attribute :good_id, :integer
    attribute :good_name, :string
    
    attribute :number, :integer, default: 1
    attribute :quantity, :decimal, default: 0  # 重量
    attribute :unit, :string  # 单位

    attribute :single_price, :decimal, default: 0  # 一份产品的价格
    attribute :original_amount, :decimal, default: 0  # 合计份数之后的价格，商品原价

    attribute :additional_amount, :decimal, default: 0  # 附加服务价格汇总
    attribute :reduced_amount, :decimal, default: 0  # 已优惠的价格
    
    attribute :retail_price, :decimal, default: 0  # 单个商品零售价(商品原价 + 服务价)
    attribute :wholesale_price, :decimal, default: 0  # 多个商品批发价
    
    attribute :amount, :decimal, default: 0
    attribute :note, :string
    attribute :advance_amount, :decimal, default: 0
    attribute :extra, :json, default: {}

    belongs_to :good, polymorphic: true
    belongs_to :trade, polymorphic: true, inverse_of: :trade_items
    has_many :trade_promotes, -> { includes(:promote).single }, inverse_of: :trade_item, dependent: :destroy
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
    
    after_initialize if: :new_record? do
      self.good_name = good.name
      self.single_price = good.price
    end
    after_save :sync_changed_amount, if: -> { (saved_changes.keys & ['amount', 'additional_amount', 'reduced_amount']).present? }
    after_commit :sync_cart_charges, :total_cart_charges, if: -> { number_changed? }, on: [:create, :update]
  end

  def origin_quantity
    good.unified_quantity * self.number
  end

  # 批发价和零售价之间的差价，即批发折扣
  def discount_price
    wholesale_price - (retail_price * number)
  end
  
  def init_amount
    self.original_amount = single_price * number
    self.advance_amount = good.advance_price
    self.amount = original_amount
    trade.item_amount += amount
    trade.amount += amount
  end

  def compute_promote
    good.valid_promote_goods.map do |promote_good|
      value = metering_attributes.fetch(promote_good.promote.metering)
      promote_charge = promote_good.promote.compute_charge(value, **extra)
      next unless promote_charge
      if promote_good.promote.single?
        tp = self.trade_promotes.build(promote_charge_id: promote_charge.id, promote_good_id: promote_good.id)
      else
        tp = trade.trade_promotes.build(promote_charge_id: promote_charge.id, promote_good_id: promote_good.id)
      end
      tp.compute_amount
    end
  
    trade.buyer.promote_buyers.each do |promote_buyer|
      value = metering_attributes.fetch(promote_buyer.promote.metering)
      promote_charge = promote_buyer.promote.compute_charge(value, **extra)
      next unless promote_charge
      if promote_good.promote.single?
        tp = self.trade_promotes.build(promote_charge_id: promote_charge.id, promote_buyer_id: promote_buyer.id, promote_good_id: promote_buyer.promote_good_id)
      else
        tp = trade.trade_promotes.build(promote_charge_id: promote_charge.id, promote_buyer_id: promote_buyer.id, promote_good_id: promote_buyer.promote_good_id)
      end
      tp.compute_amount
    end
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
    self.amount = original_amount + additional_amount + reduced_amount
    
    changed_amount = amount - amount_was.to_i
    trade.item_amount += changed_amount
    trade.amount += changed_amount
    if trade.amount == compute_saved_amount
      trade.save!
    else
      trade.errors.add :amount, 'not equal'
      logger.error "#{self.class.name}/Trade: #{trade.error_text}"
      raise ActiveRecord::RecordInvalid.new(trade)
    end
  end

  def valid_promote_buyers(buyer)
    ids = (available_promote_ids & buyer.all_promote_ids) - buyer.promote_buyers.pluck(:promote_id)
    Promote.where(id: ids)
  end
  
  def metering_attributes
    attributes.slice 'quantity', 'amount', 'number'
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


end
