class TotalCart < ApplicationRecord
  include RailsTrade::TotalCart
  include RailsTrade::Amount
end unless defined? TotalCart
