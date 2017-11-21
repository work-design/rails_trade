class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  validates :buyer_id, presence: true, if: -> { session_id.blank? }
  validates :session_id, presence: true, if: -> { buyer_id.blank? }
  scope :valid, -> { default_where(status: 'unpaid') }
  scope :checked, -> { default_where(checked: true) }

  enum status: [
    :unpaid,
    :paid,
    :deleted
  ]

  composed_of :fee,
              class_name: 'PromoteFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']]

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


    charge.discount = charge.discount_price(good.quantity, number) if number > 1 && promote.discount

  end

  def subtotal
    total_subtotal + discount_subtotal
  end

  def same_cart_items
    if self.buyer_id
      CartItem.where(buyer_id: self.buyer_id).valid
    else
      CartItem.where(session_id: self.session_id).valid
    end
  end

end
