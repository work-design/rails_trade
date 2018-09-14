class OrderServe < ApplicationRecord
  belongs_to :order, inverse_of: :order_serves
  belongs_to :order_item, optional: true
  belongs_to :serve_charge, optional: true
  belongs_to :serve

  after_update_commit :sync_amount, if: -> { saved_change_to_amount? }

  def sync_amount
    if self.order_item_id.nil?
      order.compute_sum
      order.save
    else
      order_item.compute_sum
      order_item.save
    end
  end

end unless TheTrade.config.disabled_models.include?('OrderServe')

# :order_id, :integer
# :order_item_id :integer

