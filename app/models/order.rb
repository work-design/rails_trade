class Order < ApplicationRecord
  include RailsTrade::Order
end unless defined? Order
