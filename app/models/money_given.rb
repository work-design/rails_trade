class MoneyGiven < ApplicationRecord
  include RailsVip::MoneyGiven
end unless defined? MoneyGiven
