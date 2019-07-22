class PaymentType < ApplicationRecord
  include RailsTrade::PaymentType
end unless defined? PaymentType
