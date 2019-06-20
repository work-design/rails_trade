module RailsTrade::CartPromote
  extend ActiveSupport::Concern
  included do
    attribute :cart_item_id, :integer
    attribute :serve_id, :integer
    attribute :good_type, :string
    attribute :good_id, :integer
    attribute :sequence, :integer
    attribute :scope, :string
    attribute :based_amount, :decimal  # 基于此价格计算，默认为cart_item 的 amount，与sequence有关
    attribute :amount, :decimal  # 算出的实际价格
    attribute :original_amount, :decimal  # 默认和amount 相等，如果客服人员修改过价格后，则amount 会发生变化
    
    belongs_to :cart
    belongs_to :cart_item, touch: true, optional: true
    belongs_to :good, polymorphic: true
    belongs_to :promote_charge
    belongs_to :promote
    belongs_to :promote_buyer
    belongs_to :promote_good
    
    validates :promote_id, uniqueness: { scope: [:cart_item_id] }
    validates :amount, presence: true

    enum state: {
      init: 'init',
      checked: 'checked'
    }
    enum scope: {
      single: 'single',
      overall: 'overall'
    }

    after_initialize if: :new_record? do
      if cart_item
        self.cart_id = cart_item.cart_id
      end
      if self.promote_charge
        self.promote_id = self.promote_charge.promote_id
      end
      if self.promote
        self.sequence = self.promote.sequence
        self.scope = self.promote.scope
      end
    end
    before_validation :compute_amount
  end

  def compute_amount
    if single?
      value = cart_item.send(promote_charge.metering)
    else
      value = cart.send(promote_charge.metering)
    end
    
    self.amount = self.promote_charge.final_price(value)
  end
  
end
