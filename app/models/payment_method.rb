class PaymentMethod < ApplicationRecord
  include RailsTrade::PaymentMethod
end unless defined? PaymentMethod
