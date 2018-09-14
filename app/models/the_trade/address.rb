class Address < ApplicationRecord
  belongs_to :area, optional: true

  enum kind: {
    transport: 'transport',
    forwarder: 'forwarder',
    invoice: 'invoice'
  }

  after_initialize if: :new_record? do |t|
    self.buyer_id = self.user&.buyer_id
  end

end unless TheTrade.config.disabled_models.include?('Address')