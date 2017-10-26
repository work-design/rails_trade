class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  scope :valid, -> { default_where(status: 'unpaid') }

  enum status: [
    :unpaid,
    :paid,
    :deleted
  ]

  after_initialize if: :new_record? do |t|
    self.status = 'unpaid'
  end

end
