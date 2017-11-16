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
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number']]

  after_initialize if: :new_record? do |t|
    self.status = 'unpaid'
  end

  def total_subtotal
    self.fee.total_subtotal
  end

  def single_subtotal
    self.fee.single_subtotal
  end

  def discount_subtotal
    self.fee.discount_subtotal
  end

  def subtotal
    total_subtotal + discount_subtotal
  end

  def self.total(params)
    cart_item_ids = params[:cart_item_ids].split(',')
    cart_items = CartItem.where(id: cart_item_ids)
    subtotal = cart_items.sum { |cart_item| cart_item.subtotal }
    discount_subtotal = cart_items.sum { |cart_item| cart_item.discount_subtotal }
    total_subtotal = cart_items.sum { |cart_item| cart_item.total_subtotal }

    [total_subtotal, discount_subtotal, subtotal]
  end

end
