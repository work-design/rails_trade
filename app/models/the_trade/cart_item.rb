class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  belongs_to :buyer, class_name: '::Buyer', optional: true
  belongs_to :user, optional: true
  has_many :cart_item_serves, dependent: :destroy

  validates :user_id, presence: true, if: -> { session_id.blank? }
  validates :session_id, presence: true, if: -> { user_id.blank?  }
  scope :valid, -> { default_where(status: 'init', assistant: false) }
  scope :checked, -> { default_where(checked: true) }

  enum status: [
    :init,
    :ordered,
    :archived,
    :deleted
  ]

  composed_of :serve,
              class_name: 'ServeFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']],
              constructor: Proc.new { |type, id, num, buyer| ServeFee.new(type, id, num, buyer) }

  composed_of :promote,
              class_name: 'PromoteFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']],
              constructor: Proc.new { |type, id, num, buyer| PromoteFee.new(type, id, num, buyer) }

  after_initialize if: :new_record? do |t|
    self.status = 'init'
    self.buyer_id = self.user&.buyer_id
    self.quantity = 1 if self.quantity < 1
  end

  def pure_price
    good.price.to_d * quantity
  end

  def retail_price
    self.good.retail_price * self.quantity
  end

  def discount_price
    if quantity > 1
      -(retail_price - bulk_price)
    else
      0
    end
  end

  def promote_price
    self.promote.subtotal
  end

  def bulk_price
    pure_price + self.serve.subtotal
  end

  def server_subtotal
    cart_item_serves.each do |cart_item_serve|
      serve.charges.find { |charge| .pluck(:serve_id).include? charge.server_id }.each do |charge|
        charge.cart_item_serve = cart_item_serve
        charge.subtotal = cart_item_serve.price
      end
    end
  end

  def final_price
    self.bulk_price + self.promote.subtotal
  end

  def total_quantity
    good.quantity.to_d * self.quantity
  end

  def same_cart_items
    if self.user_id
      CartItem.where(buyer_id: self.user_id).valid
    else
      CartItem.where(session_id: self.session_id).valid
    end
  end

end
