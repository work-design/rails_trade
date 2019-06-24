module RailsTrade::TradePromote
  METERING = ['weight', 'colume', 'amount'].freeze
  extend ActiveSupport::Concern
  included do
    attribute :sequence, :integer
    attribute :scope, :string
    attribute :based_amount, :decimal, default: 0  # 基于此价格计算，默认为cart_item 的 amount，与sequence有关
    attribute :original_amount, :decimal, default: 0  # 默认和amount 相等，如果客服人员修改过价格后，则amount 会发生变化
    attribute :amount, :decimal, default: 0  # 算出的实际价格

    belongs_to :trade, polymorphic: true, inverse_of: :trade_promotes
    belongs_to :trade_item, optional: true
    belongs_to :promote
    belongs_to :promote_charge
    belongs_to :promote_buyer, counter_cache: true, optional: true
    belongs_to :promote_good, optional: true
    
    validates :promote_id, uniqueness: { scope: [:cart_item_id] }
    validates :amount, presence: true
    
    enum scope: {
      single: 'single',
      overall: 'overall'
    }

    after_initialize if: :new_record? do
      if trade_item
        self.trade = trade_item.trade
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
    after_create_commit :check_promote_buyer
  end

  def compute_amount
    if single?
      value = item.send(promote_charge.metering)
      if METERING.include?(promote_charge.metering)
        added_amount = item.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(promote_charge.metering)
      else
        added_amount = 0
      end
      self.based_amount = value + added_amount
    else
      value = trade.send(promote_charge.metering)
      if METERING.include?(promote_charge.metering)
        added_amount = trade.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(promote_charge.metering)
      else
        added_amount = 0
      end
      
      self.based_amount = value + added_amount
    end
    
    self.amount = self.promote_charge.final_price(based_amount)
  end

  def check_promote_buyer
    return unless promote_buyer
    self.promote_buyer.update state: 'used'
  end
  
end
