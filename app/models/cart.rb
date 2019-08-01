class Cart < ApplicationRecord
  include RailsTrade::Cart
  include RailsTrade::Amount
end unless defined? Cart
