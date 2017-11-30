class Address < ApplicationRecord
  belongs_to :buyer, optional: true
  belongs_to :user, optional: true
  belongs_to :area, optional: true

  enum kind: [
    :transport,
    :forwarder,
    :invoice
  ]

  after_initialize if: :new_record? do |t|
    self.buyer_id = self.user&.buyer_id
  end

end