class Address < ApplicationRecord
  belongs_to :buyer, optional: true
  
  enum kind: [
    :transport,
    :forwarder,
    :invoice
  ]

end