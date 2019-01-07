class CartPromote < ApplicationRecord
  belongs_to :cart
  belongs_to :cart_item, touch: true
  belongs_to :promote

  validates :promote_id, uniqueness: { scope: [:cart_item_id] }
  validates :price, presence: true

  after_initialize if: :new_record? do |t|
    self.scope = self.promote.scope
  end

end unless RailsTrade.config.disabled_models.include?('CartPromote')
