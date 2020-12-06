class Payout < ApplicationRecord
  include RailsVip::Payout
end unless defined? Payout
