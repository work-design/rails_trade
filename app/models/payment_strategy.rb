class PaymentStrategy < ApplicationRecord
  include RailsTrade::PaymentStrategy
end unless defined? PaymentStrategy
