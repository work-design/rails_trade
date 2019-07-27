module RailsTrade::TradePromote
  METERING = ['weight', 'colume', 'amount'].freeze
  extend ActiveSupport::Concern
  included do
    attribute :sequence, :integer
    attribute :scope, :string
    attribute :based_amount, :decimal, default: 0  # 基于此价格计算，默认为 trade_item 的 amount，与sequence有关
    attribute :original_amount, :decimal, default: 0  # 默认和 amount 相等，如果客服人员修改过价格后，则amount 会发生变化
    attribute :computed_amount, :decimal, default: 0  # 默认计算出的价格，默认为amount
    attribute :amount, :decimal, default: 0  # 算出的实际价格
    attribute :note, :string  # 备注
    
    belongs_to :trade, polymorphic: true, inverse_of: :trade_promotes
    belongs_to :trade_item, optional: true
    belongs_to :promote
    belongs_to :promote_charge
    belongs_to :promote_good
    belongs_to :promote_buyer, counter_cache: true, optional: true
    
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
      if self.promote_good
        self.promote_id = self.promote_good.promote_id
        self.sequence = self.promote.sequence
        self.scope = self.promote.scope
      end
    end
    before_validation :compute_amount
    after_create_commit :check_promote_buyer
  end

  def compute_amount
    if single?
      value = trade_item.metering_attributes.fetch(promote.metering)
      if METERING.include?(promote.metering)
        added_amount = trade_item.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(promote.metering)
      else
        added_amount = 0
      end
      
      self.based_amount = value + added_amount
    else
      value = trade.send(promote.metering)
      if METERING.include?(promote.metering)
        added_amount = trade.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(promote.metering)
      else
        added_amount = 0
      end
      
      self.based_amount = value + added_amount
    end

    self.promote_charge = promote.compute_charge(based_amount, **extra)
    self.amount = self.promote_charge.final_price(based_amount)
  end

  def check_promote_buyer
    return unless promote_buyer
    self.promote_buyer.update state: 'used'
  end
  
end
