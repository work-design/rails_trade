class Cash < ApplicationRecord
  include RailsTrade::Cash
  include RailsTrade::Compute
end unless defined? Cash
