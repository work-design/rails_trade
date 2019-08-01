module RailsTrade::Amount
  extend ActiveSupport::Concern
  included do
    attribute :item_amount, :decimal, default: 0
    attribute :overall_additional_amount, :decimal, default: 0
    attribute :overall_reduced_amount, :decimal, default: 0
    attribute :amount, :decimal, default: 0

    after_save :sync_changed_amount, if: -> { (saved_changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
  end

  def sync_changed_amount!
    sync_changed_amount
    self.save
  end

  def sync_changed_amount
    self.amount = item_amount + overall_additional_amount + overall_reduced_amount
  end

  def compute_amount
    self.item_amount = trade_items.sum(&:amount)
    self.overall_additional_amount = trade_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
    self.overall_reduced_amount = trade_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)
    self.amount = item_amount + overall_additional_amount + overall_reduced_amount
    self
  end
  
  def compute_saved_amount
    _item_amount = trade_items.sum(:amount)
    _promote_amount = trade_promotes.sum(:amount)
    _item_amount + _promote_amount
  end
  
end
