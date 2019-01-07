class OrderPromote < ApplicationRecord
  attribute :order_id, :integer
  attribute :order_item_id, :integer

  belongs_to :order, inverse_of: :order_promotes
  belongs_to :order_item, optional: true
  belongs_to :promote
  belongs_to :promote_charge, optional: true

end unless RailsTrade.config.disabled_models.include?('OrderPromote')
