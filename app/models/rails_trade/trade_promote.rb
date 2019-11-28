module RailsTrade::TradePromote
  extend ActiveSupport::Concern
  included do
    attribute :sequence, :integer
    attribute :scope, :string
    attribute :based_amount, :decimal, precision: 10, scale: 2, default: 0, comment: '基于此价格计算，默认为 trade_item 的 amount，与sequence有关'
    attribute :computed_amount, :decimal, precision: 10, scale: 2, default: 0, comment: '计算出的价格'
    attribute :amount, :decimal, precision: 10, scale: 2, default: 0, comment: '默认等于 computed_amount，如果客服人员修改过价格后，则 amount 会发生变化'
    attribute :note, :string, comment: '备注'
    
    belongs_to :trade, polymorphic: true, inverse_of: :trade_promotes
    belongs_to :trade_item, optional: true
    belongs_to :promote
    belongs_to :promote_charge
    belongs_to :promote_good
    belongs_to :promote_buyer, counter_cache: true, optional: true
    
    validates :promote_id, uniqueness: { scope: [:trade_type, :trade_id, :trade_item_id] }
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
    after_update :sync_changed_amount, if: -> { saved_change_to_amount? }
    after_create_commit :check_promote_buyer
  end

  def compute_amount
    if single?
      value = trade_item.metering_attributes.fetch(promote.metering, 0)
      added_amount = trade_item.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(&->(o){ o.send(promote.metering) })
      
      self.based_amount = value + added_amount
    else
      value = trade.metering_attributes.fetch(promote.metering, 0)
      added_amount = trade.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(&->(o){ o.send(promote.metering) })
      
      self.based_amount = value + added_amount
    end

    self.computed_amount = self.promote_charge.final_price(based_amount)
    self.amount = computed_amount if amount.zero?
    self
  end
  
  def sync_changed_amount
    if amount >= 0 && amount_before_last_save >= 0
      _additional_amount = amount - amount_before_last_save
      _reduced_amount = 0
    elsif amount >= 0 && amount_before_last_save < 0
      _additional_amount = amount
      _reduced_amount = -amount_before_last_save
    elsif amount < 0 && amount_before_last_save >= 0
      _additional_amount = -amount_before_last_save
      _reduced_amount = amount
    else  # amount < 0 && amount_before_last_save < 0
      _additional_amount = 0
      _reduced_amount = amount - amount_before_last_save
    end
    
    if overall?
      trade.overall_additional_amount += _additional_amount
      trade.overall_reduced_amount += _reduced_amount
      trade.amount += (_additional_amount + _reduced_amount)
      trade.save!
    elsif single?
      trade_item.additional_amount += _additional_amount
      trade_item.reduced_amount += _reduced_amount
      trade_item.amount += (_additional_amount + _reduced_amount)
      trade_item.save!
    end
  end

  def check_promote_buyer
    return unless promote_buyer
    self.promote_buyer.update state: 'used'
  end
  
end
