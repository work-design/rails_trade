class Payout < ApplicationRecord
  include RailsTrade::Payout
end unless defined? Payout
