class PromoteGood < ApplicationRecord
  belongs_to :good, polymorphic: true
  belongs_to :promote

end unless TheTrade.config.disabled_models.include?('PromoteGood')

# :order_id, :integer
# :order_item_id :integer

