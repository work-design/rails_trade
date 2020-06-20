module RailsTrade::Amount
  extend ActiveSupport::Concern
  included do
    attribute :item_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :overall_additional_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :overall_reduced_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :total_additional_amount, :decimal, default: 0
    attribute :total_reduced_amount, :decimal, default: 0
    attribute :original_amount, :decimal, default: 0, comment: '原价，应用优惠之前的价格'
    attribute :amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :trade_items_count, :integer, default: 0
    attribute :lock_version, :integer
  end

  def reset_amount
    self.compute_amount
    self.valid?
    self.changes
  end

  def metering_attributes
    attributes.slice 'quantity', 'original_amount'
  end

  def reset_amount!(*args)
    self.reset_amount
    self.save(*args)
  end

end
