class PaymentReference < ApplicationRecord
  belongs_to :payment_method, autosave: true, inverse_of: :payment_references
  belongs_to :buyer, autosave: true, inverse_of: :payment_references

end
