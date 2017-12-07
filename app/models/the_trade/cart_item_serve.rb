class CartItemServe < ApplicationRecord
  belongs_to :cart_item
  belongs_to :serve

  validates :serve_id, uniqueness: { scope: [:cart_item_id] }

end


# :cart_item_id, :integer
# :serve_id, :integer
