class PaymentOrder < ApplicationRecord
  include RailsTrade::PaymentOrder
end unless defined? PaymentOrder
