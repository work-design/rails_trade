class Advance < ApplicationRecord
  include RailsTrade::Good
  include RailsVip::Advance
end unless defined? Advance
