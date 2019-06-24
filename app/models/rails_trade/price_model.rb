module RailsTrade::PriceModel
  extend ActiveSupport::Concern

  included do
    attribute :good_type, :string
    attribute :good_id, :integer
    
    attribute :number, :integer, default: 1
    attribute :quantity, :decimal, default: 0
    attribute :unit, :string
    
    attribute :single_price, :decimal, default: 0  # 一份产品的价格
    attribute :original_price, :decimal, default: 0  # 商品原价，合计份数之后
    attribute :good_sum, :decimal, default: 0

    attribute :additional_price, :decimal, default: 0  # 附加服务价格汇总
    attribute :reduced_price, :decimal, default: 0  # 已优惠的价格
    attribute :promote_sum, :decimal, default: 0
    
    attribute :amount, :decimal, default: 0

    belongs_to :good, polymorphic: true
  end

  def compute_amount_items
    self.single_price = good.price
    self.original_price = good.price * number
  
    self.additional_price = entity_promotes.select { |cp| cp.amount >= 0 }.sum(&:amount)
    self.reduced_price = entity_promotes.select { |cp| cp.amount < 0 }.sum(&:amount)  # 促销价格
    self.promote_sum = entity_promotes.select(&:single?).sum(&:amount)
    
    self.amount = good_sum + promote_sum
    self.amount = original_price + additional_price + reduced_price  # 最终价格
  end

end
