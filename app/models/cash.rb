class Cash < ApplicationRecord
  include RailsTrade::Cash
  include RailsTrade::Amount
end unless defined? Cash
