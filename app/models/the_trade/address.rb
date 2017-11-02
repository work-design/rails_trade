class Address < ApplicationRecord
  belongs_to :buyer, optional: true
  
  enum address_type: [
    :company_address,
    :forwarders_address,
    :invoice_address
  ]

end