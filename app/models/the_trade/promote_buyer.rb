class PromoteBuyer < ApplicationRecord
  belongs_to :promote


end unless TheTrade.config.disabled_models.include?('PromoteBuyer')

# :order_id, :integer
# :order_item_id :integer

