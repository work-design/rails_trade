class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  belongs_to :buyer, class_name: '::Buyer', optional: true
  validates :buyer_id, presence: true, if: -> { session_id.blank? }
  validates :session_id, presence: true, if: -> { buyer_id.blank? }
  scope :valid, -> { default_where(status: 'unpaid') }
  scope :checked, -> { default_where(checked: true) }

  enum status: [
    :unpaid,
    :paid,
    :deleted
  ]

  composed_of :promote,
              class_name: 'PromoteFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']],
              constructor: Proc.new { |type, id, num, buyer| PromoteFee.new(type, id, num, buyer) }
  composed_of :serve,
              class_name: 'ServeFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']],
              constructor: Proc.new { |type, id, num, buyer| PromoteFee.new(type, id, num, buyer) }

  after_initialize if: :new_record? do |t|
    self.status = 'unpaid'
  end

  def total_subtotal
    self.fee.subtotal
  end

  def discount_subtotal
    if number > 1
      -(self.good.fee.subtotal * self.quantity - self.fee.subtotal)
    else
      0
    end
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
