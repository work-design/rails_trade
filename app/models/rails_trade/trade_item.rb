module RailsTrade::TradeItem
  extend ActiveSupport::Concern
  include RailsTrade::ItemPromote

  included do
    attribute :status, :string, default: 'init'
    attribute :myself, :boolean, default: true  # 是否后台协助添加
    attribute :starred, :boolean, default: false  # 收藏
    
    attribute :good_type, :string
    attribute :good_id, :integer

    attribute :number, :integer, default: 1
    attribute :quantity, :decimal, default: 0
    attribute :unit, :string

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
    belongs_to :trade, counter_cache: true, polymorphic: true, autosave: true, inverse_of: :trade_items
    has_many :trade_promotes, -> { includes(:promote) }, as: :item, autosave: true, dependent: :destroy
    has_many :providers, dependent: :delete_all  # 用于对接供应商

    scope :valid, -> { where(status: 'init', myself: true) }
    scope :starred, -> { where(status: 'init', starred: true) }
    
    enum status: {
      init: 'init',
      checked: 'checked',
      ordered: 'ordered',
      deleted: 'deleted'
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
  
  class_methods do
    
    def good_types
      CartItem.select(:good_type).distinct.pluck(:good_type)
    end
    
  end

end
