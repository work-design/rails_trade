class PaymentOrder < ApplicationRecord
  include RailsTrade::PaymentOrder
  include RailsCom::Debug
end unless defined? PaymentOrder
