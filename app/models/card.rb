class Card < ApplicationRecord
  include RailsTrade::Card
  include RailsTrade::Compute
end unless defined? Card
