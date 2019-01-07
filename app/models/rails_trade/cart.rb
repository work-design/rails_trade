# 数据定期清理
# 改变数据动作：
#   * 新增(check)
#   * 更新数量
#   * 选择或更换优惠券
#   * 选择服务
class Cart < ApplicationRecord
  belongs_to :buyer, polymorphic: true, optional: true
  has_many :cart_items, ->(o){ where(buyer_type: o.buyer_type) }, primary_key: :buyer_id, foreign_key: :buyer_id
  has_many :cart_serves, -> { includes(:serve) }, dependent: :destroy
  has_many :cart_promotes, -> { includes(:promote) }, dependent: :destroy

end
