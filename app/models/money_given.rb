class MoneyGiven < ApplicationRecord
  include RailsTrade::MoneyGiven
end unless defined? MoneyGiven
