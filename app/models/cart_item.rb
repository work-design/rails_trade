class CartItem < ApplicationRecord
  include RailsTrade::CartItem
  include RailsTrade::ItemPrice
end unless defined? CartItem
