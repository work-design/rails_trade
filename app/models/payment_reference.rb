class PaymentReference < ApplicationRecord
  belongs_to :payment_method
  belongs_to :buyer

end
