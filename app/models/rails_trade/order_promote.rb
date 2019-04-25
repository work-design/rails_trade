module RailsTrade::OrderPromote
  extend ActiveSupport::Concern
  included do
    attribute :order_id, :integer
    attribute :order_item_id, :integer
    attribute :amount, :decimal, default: 0
  
    belongs_to :order, inverse_of: :order_promotes
    belongs_to :order_item, optional: true
    belongs_to :promote
    belongs_to :promote_charge, optional: true
    belongs_to :promote_buyer, optional: true, counter_cache: true
    after_create_commit :check_promote_buyer
  
    after_initialize if: :new_record? do
      self.order = self.order_item.order
      compute_amount
    end
  end

  def check_promote_buyer
    return unless promote_buyer
    self.promote_buyer.update state: 'used'
  end

  def compute_amount
    promote_charge, amount = self.promote.compute_amount(order_item.good, order_item.number, order_item.extra)
    self.amount = amount
    self.promote_charge_id = promote_charge.id
  end

end
