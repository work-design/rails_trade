class Payment < ApplicationRecord
  include RailsTrade::Payment
end unless defined? Payment
