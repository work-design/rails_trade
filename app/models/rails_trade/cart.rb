# 数据定期清理
class Cart < ApplicationRecord
  has_many :cart_serves, -> { includes(:serve) }, dependent: :destroy
  has_many :cart_promotes, dependent: :destroy

end
