class OrderItem < ApplicationRecord
  include RailsTrade::OrderItem
end unless defined? OrderItem
