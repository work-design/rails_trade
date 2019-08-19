# 数据定期清理
# 改变数据动作：
#   * 新增(check)
#   * 更新数量
#   * 选择或更换优惠券
#   * 选择服务
module RailsTrade::Cart
  extend ActiveSupport::Concern
  
  included do
    attribute :retail_price, :decimal, default: 0  # 商品汇总的原价
    attribute :discount_price, :decimal, default: 0
    attribute :bulk_price, :decimal, default: 0
    
    attribute :reduced_amount, :decimal, default: 0  # 汇总的减少价格
    attribute :additional_amount, :decimal, default: 0
    attribute :total_quantity, :decimal, default: 0
    
    attribute :deposit_ratio, :integer, default: 100  # 最小预付比例
    attribute :payment_strategy_id, :integer
    attribute :default, :boolean, default: false

    belongs_to :user, optional: true
    belongs_to :buyer, polymorphic: true, optional: true
    belongs_to :payment_strategy, optional: true
    has_many :orders, dependent: :nullify
    
    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

    validates :user_id, presence: true, if: -> { session_id.blank? }
    validates :session_id, presence: true, if: -> { user_id.blank? }
    
    after_update :set_default, if: -> { self.default? && saved_change_to_default? }
  end

  def compute_price
    self.retail_price = trade_items.checked.sum(&:retail_price)
    self.discount_price = trade_items.checked.sum(&:discount_price)
    self.bulk_price = self.retail_price - self.discount_price

    self.reduced_amount = trade_items.checked.sum(&:reduced_amount)
    self.additional_amount = trade_items.checked.sum(&:additional_amount)
    
    self.amount = trade_items.checked.sum(&:amount)
    
    self.total_quantity = trade_items.checked.sum(&:original_quantity)
  end
 
  def migrate_to_order(myself: true)
    o = self.orders.build
    trade_items.checked.default_where(myself: myself).each do |trade_item|
      trade_item.trade = o
    end
    
    trade_promotes.each do |trade_promote|
      trade_promote.trade = o
    end
    o
  end

  def set_default
    self.class.where.not(id: self.id).where(user_id: self.user_id).update_all(default: false)
  end
  
  class_methods do
    
    def default
      find_by(default: true)
    end
    
  end

end
