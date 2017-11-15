class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  scope :valid, -> { default_where(status: 'unpaid') }

  enum status: [
    :unpaid,
    :paid,
    :deleted
  ]

  composed_of :fee,
              class_name: 'PromoteFee',
              mapping: [['product_type', 'good_type'], ['product_id', 'good_id'], ['quantity', 'number']]

  after_initialize if: :new_record? do |t|
    self.status = 'unpaid'
  end

  def total_subtotal
    self.fee.single_subtotal * self.quantity.to_i
  end

  def single_subtotal
    self.fee.single_subtotal
  end

end
