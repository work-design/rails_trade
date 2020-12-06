class Cash < ApplicationRecord
  include RailsVip::Cash
  include RailsVip::Amount
end unless defined? Cash
