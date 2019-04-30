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
    attribute :deposit_ratio, :integer, default: 100  # 最小预付比例
    attribute :payment_strategy_id, :integer
    attribute :default, :boolean, default: false

    belongs_to :user, optional: true
    belongs_to :buyer, polymorphic: true, optional: true
    belongs_to :payment_strategy, optional: true
    has_many :cart_items, ->(o){ where(buyer_type: o.buyer_type) }, primary_key: :buyer_id, foreign_key: :buyer_id
    has_many :checked_items, ->(o){ where(buyer_type: o.buyer_type, checked: true) }, class_name: 'CartItem', primary_key: :buyer_id, foreign_key: :buyer_id
    has_many :cart_serves, -> { includes(:serve) }, dependent: :destroy
    has_many :cart_promotes, -> { includes(:promote) }, dependent: :destroy

    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

    after_update :set_default, if: -> { self.default? && saved_change_to_default? }
  end

  def compute_price
    self.reduced_price = checked_items.sum(:reduced_price)
    self.discount_price = checked_items.sum(:discount_price)
    self.retail_price = checked_items.sum(:retail_price)
    self.final_price = checked_items.sum(:final_price)
    self.total_quantity = checked_items.sum(:total_quantity)
  end

  def set_default
    self.class.where.not(id: self.id).where(user_id: self.user_id).update_all(default: false)
  end

end
