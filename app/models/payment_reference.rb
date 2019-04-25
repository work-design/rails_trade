class PaymentReference < ApplicationRecord
  include RailsTrade::PaymentReference
end unless defined? PaymentReference
