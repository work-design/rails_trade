# 数据定期清理
# 改变数据动作：
#   * 新增
#   * 更新数量
#   * check
#   * 选择或更换优惠券
#   * 选择服务
class Cart < ApplicationRecord
  has_many :cart_serves, -> { includes(:serve) }, dependent: :destroy
  has_many :cart_promotes, dependent: :destroy

end
