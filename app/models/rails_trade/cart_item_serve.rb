class CartItemServe < ApplicationRecord
  belongs_to :cart_item, touch: true
  belongs_to :serve

  validates :serve_id, uniqueness: { scope: [:cart_item_id] }
  validates :price, presence: true

  after_initialize if: :new_record? do |t|
    self.scope = self.serve.scope
  end

end unless RailsTrade.config.disabled_models.include?('CartItemServe')


# :cart_item_id, :integer
# :serve_id, :integer
