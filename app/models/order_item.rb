class OrderItem < ApplicationRecord
  include RailsTrade::OrderItem
  include RailsTrade::ItemPrice
end unless defined? OrderItem
