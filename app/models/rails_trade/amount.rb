module RailsTrade::Amount
  extend ActiveSupport::Concern
  included do
    attribute :item_amount, :decimal, default: 0
    attribute :overall_additional_amount, :decimal, default: 0
    attribute :overall_reduced_amount, :decimal, default: 0
    attribute :total_additional_amount, :decimal, default: 0
    attribute :total_reduced_amount, :decimal, default: 0
    attribute :amount, :decimal, default: 0
    attribute :trade_items_count, :integer, default: 0
    attribute :lock_version, :integer

    has_many :trade_items, as: :trade, inverse_of: :trade, dependent: :destroy
    has_many :trade_promotes, -> { where(trade_item_id: nil) }, as: :trade, inverse_of: :trade, dependent: :destroy  # overall can be blank

    accepts_nested_attributes_for :trade_items
    accepts_nested_attributes_for :trade_promotes
  end

  def reset_amount
    self.compute_amount
    self.valid?
    self.changes
  end

  def reset_amount!(*args)
    self.reset_amount
    self.save(*args)
  end

end
