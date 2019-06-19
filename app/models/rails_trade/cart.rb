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
    has_many :cart_items, dependent: :destroy
    has_many :cart_promotes, -> { includes(:promote) }, dependent: :destroy
    
    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

    validates :user_id, presence: true, if: -> { session_id.blank? }
    validates :session_id, presence: true, if: -> { user_id.blank? }
    
    after_update :set_default, if: -> { self.default? && saved_change_to_default? }
  end

  def compute_price
    self.reduced_price = cart_items.checked.sum(:reduced_price)
    self.discount_price = cart_items.checked.sum(:discount_price)
    self.retail_price = cart_items.checked.sum(:retail_price)
    self.final_price = cart_items.checked.sum(:final_price)
    self.total_quantity = cart_items.checked.sum(:total_quantity)
  end

  def set_default
    self.class.where.not(id: self.id).where(user_id: self.user_id).update_all(default: false)
  end

  def sync_cart_charges
    available_promote_ids = []
    extra = {}
    [:quantity, :number, :amount].each do |m|
      value = send("total_#{m}")
      q_params = {
        promote_id: available_promote_ids,
        'promote.scope': 'total',
        metering: m.to_s,
        'min-lte': value,
        'max-gte': value,
        **extra
      }
    
      charges = PromoteCharge.default_where(q_params)
      charges.reject! do |charge|
        (charge.max == value && !charge.contain_max) || (charge.min == value && !charge.contain_min)
      end
      charges.each do |promote_charge|
        self.cart_promotes.build(promote_charge_id: promote_charge.id)
      end
    end
  end
  
  class_methods do
    
    def default
      find_by(default: true)
    end
    
  end

end
