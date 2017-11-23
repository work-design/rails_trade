class Address < ApplicationRecord
  belongs_to :buyer, optional: true
  belongs_to :area, optional: true
  
  enum kind: [
    :transport,
    :forwarder,
    :invoice
  ]

end