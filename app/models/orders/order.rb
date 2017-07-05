class Order < ApplicationRecord
  include OrderAble





  after_initialize if: :new_record? do |o|
    self.uuid = UidHelper.nsec_uuid('OD')
  end

  enum payment_status: {
    unpaid: 0,
    part_paid: 1,
    all_paid: 2,
    refunded: 3
  }

end

# :buyer_id, :integer
# :amount, :decimal

