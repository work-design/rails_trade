class CartPromote < ApplicationRecord
  belongs_to :cart
  belongs_to :cart_item, touch: true
  belongs_to :promote_charge
  belongs_to :promote
  belongs_to :promote_buyer

  validates :promote_id, uniqueness: { scope: [:cart_item_id] }
  validates :amount, presence: true

  after_initialize if: :new_record? do |t|
    self.promote_id = self.promote_charge.promote_id
  end

  enum state: {
    init: 'init',
    checked: 'checked'
  }

end unless RailsTrade.config.disabled_models.include?('CartPromote')
