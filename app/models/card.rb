class Card < ApplicationRecord
  include RailsVip::Card
  include RailsVip::Amount
end unless defined? Card
