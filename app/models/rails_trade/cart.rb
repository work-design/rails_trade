# 数据定期清理
# 改变数据动作：
#   * 新增(check)
#   * 更新数量
#   * 选择或更换优惠券
#   * 选择服务
module RailsTrade::Cart
  extend ActiveSupport::Concern
  included do
    attribute :retail_price, :decimal

    belongs_to :buyer, polymorphic: true, optional: true
    has_many :cart_items, ->(o){ where(buyer_type: o.buyer_type) }, primary_key: :buyer_id, foreign_key: :buyer_id
    has_many :check_items, ->(o){ where(buyer_type: o.buyer_type, checked: true) }, primary_key: :buyer_id, foreign_key: :buyer_id
    has_many :cart_serves, -> { includes(:serve) }, dependent: :destroy
    has_many :cart_promotes, -> { includes(:promote) }, dependent: :destroy
  end

  def compute_price
    self.reduced_price = checked_items.sum(:reduced_price)
    self.discount_price = checked_items.sum(:discount_price)
    self.retail_price = checked_items.sum(:retail_price)
    self.final_price = checked_items.sum(:final_price)
    self.total_quantity = checked_items.sum(:total_quantity)
  end

end
