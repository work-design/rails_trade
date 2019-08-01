class Order < ApplicationRecord
  include RailsTrade::Order
  include RailsTrade::Amount
end unless defined? Order
