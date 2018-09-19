class PromoteBuyer < ApplicationRecord
  belongs_to :promote


end unless RailsTrade.config.disabled_models.include?('PromoteBuyer')

# :order_id, :integer
# :order_item_id :integer

