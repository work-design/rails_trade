class OrderPromote < ApplicationRecord
  attribute :order_id, :integer
  attribute :order_item_id, :integer

  belongs_to :order, inverse_of: :order_promotes
  belongs_to :order_item, optional: true
  belongs_to :promote
  belongs_to :promote_charge, optional: true
  belongs_to :promote_buyer, optional: true, counter_cache: true
  after_create_commit :check_promote_buyer

  def check_promote_buyer
    return unless promote_buyer
    self.promote_buyer.update state: 'used'
  end

end unless RailsTrade.config.disabled_models.include?('OrderPromote')
