class CartItem < ApplicationRecord
  include RailsTrade::CartItem
end unless defined? CartItem
