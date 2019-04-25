class Cart < ApplicationRecord
  include RailsTrade::Cart
end unless defined? Cart
