class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  belongs_to :buyer, class_name: '::Buyer', optional: true
  belongs_to :user, optional: true
  has_many :cart_item_serves, dependent: :destroy
  has_many :order_items, dependent: :nullify

  validates :user_id, presence: true, if: -> { session_id.blank? }
  validates :session_id, presence: true, if: -> { user_id.blank?  }
  scope :valid, -> { where(status: 'init', assistant: false) }
  scope :checked, -> { where(checked: true) }

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
    self.quantity = 1 if self.quantity.to_i < 1
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

  def get_charge(serve)
    charge = self.serve.get_charge(serve)
    cart_item_serve = cart_item_serves.find { |cart_item_serve| cart_item_serve.serve_id == charge.serve_id  }
    if cart_item_serve.persisted?
      charge.cart_item_serve = cart_item_serve
      charge.subtotal = cart_item_serve.price
    end
    charge
  end

  def serve_charges
    charges = []
    serve.charges.each do |charge|
      cart_item_serve = cart_item_serves.find { |cart_item_serve| cart_item_serve.serve_id == charge.serve_id  }
      if cart_item_serve
        charge.cart_item_serve = cart_item_serve
        charge.subtotal = cart_item_serve.price
      end
      charges << charge
    end

    cart_item_serves.where(scope: 'single').where.not(serve_id: serve.charges.map(&:serve_id)).each do |cart_item_serve|
      charge = self.serve.get_charge(cart_item_serve.serve)
      charge.cart_item_serve = cart_item_serve
      charge.subtotal = cart_item_serve.price
      charges << charge
    end
    charges
  end

  def total_serve_charges
    charges = []
    serve.total_charges.each do |charge|
      cart_item_serve = cart_item_serves.find { |cart_item_serve| cart_item_serve.serve_id == charge.serve_id  }
      if cart_item_serve
        charge.cart_item_serve = cart_item_serve
        charge.subtotal = cart_item_serve.price
      end
      charges << charge
    end

    cart_item_serves.where(scope: 'total').where.not(serve_id: serve.total_charges.map(&:serve_id)).each do |cart_item_serve|
      charge = self.serve.get_charge(cart_item_serve.serve)
      charge.cart_item_serve = cart_item_serve
      charge.subtotal = cart_item_serve.price
      charges << charge
    end
    charges
  end

  def for_select_serves
    @for_sales = Serve.for_sale.where.not(id: cart_item_serves.map(&:serve_id).uniq)
    @for_sales.map do |serve|
      self.serve.get_charge(serve)
    end.compact
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
