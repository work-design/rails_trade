class Address < ApplicationRecord
  belongs_to :buyer, class_name: '::Buyer', optional: true
  belongs_to :user, optional: true
  belongs_to :area, optional: true

  enum kind: {
    transport: 'transport',
    forwarder: 'forwarder',
    invoice: 'invoice'
  }

  after_initialize if: :new_record? do |t|
    self.buyer_id = self.user&.buyer_id
  end

end