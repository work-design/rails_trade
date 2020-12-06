class Card < ApplicationRecord
  include RailsTrade::Card
  include RailsTrade::Amount
end unless defined? Card
