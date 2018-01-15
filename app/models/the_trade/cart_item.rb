class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  belongs_to :buyer, class_name: '::Buyer', optional: true
  belongs_to :user, optional: true
  has_many :cart_item_serves, -> { includes(:serve) }, dependent: :destroy
  has_many :order_items, dependent: :nullify

  validates :user_id, presence: true, if: -> { session_id.blank? }
  validates :session_id, presence: true, if: -> { user_id.blank?  }
  scope :valid, -> { where(status: 'pending', myself: true) }
  scope :checked, -> { where(status: 'pending', checked: true) }

  enum status: {
    init: 'init',
    pending: 'pending',
    ordered: 'ordered',
    deleted: 'deleted'
  }

  composed_of :serve,
              class_name: 'ServeFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']],
              constructor: Proc.new { |type, id, num, buyer| ServeFee.new(type, id, num, buyer, self.extra) }

  composed_of :promote,
              class_name: 'PromoteFee',
              mapping: [['good_type', 'good_type'], ['good_id', 'good_id'], ['quantity', 'number'], ['buyer_id', 'buyer_id']],
              constructor: Proc.new { |type, id, num, buyer| PromoteFee.new(type, id, num, buyer) }

  after_initialize if: :new_record? do |t|
    self.status = 'init'
    self.buyer_id = self.user&.buyer_id
    self.quantity = 1 if self.quantity.to_i < 1
  end

  def total_quantity
    good.unified_quantity.to_d * self.quantity
  end

  # 零售价
  def retail_price
    self.good.retail_price * self.quantity
  end

  def discount_price
    bulk_price - retail_price
  end

  # 商品原价
  def pure_price
    good.price.to_d * quantity
  end

  # 附加服务价格汇总
  def serve_price
    serve_charges.sum { |i| i.subtotal }
  end

  # 促销价格
  def reduced_price
    self.promote.subtotal
  end

  # 批发价
  def bulk_price
    pure_price + serve_price
  end

  def final_price
    self.bulk_price + self.reduced_price
  end

  def total_serve_price
    total_serve_charges.sum { |i| i.subtotal }
  end

  def total_promote_price
    total.promote_charges.sum { |i| i.subtotal }
  end

  def estimate_price
    final_price + total_serve_price + total_promote_price
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
    total.serve_charges.each do |charge|
      cart_item_serve = cart_item_serves.find { |cart_item_serve| cart_item_serve.serve_id == charge.serve_id  }
      if cart_item_serve
        charge.cart_item_serve = cart_item_serve
        charge.subtotal = cart_item_serve.price
      end
      charges << charge
    end

    cart_item_serves.where(scope: 'total').where.not(serve_id: total.serve_charges.map(&:serve_id)).each do |cart_item_serve|
      charge = self.serve.get_charge(cart_item_serve.serve)
      charge.cart_item_serve = cart_item_serve
      charge.subtotal = cart_item_serve.price
      charges << charge
    end
    charges
  end

  def total_promote_charges
    total.promote_charges
  end

  def for_select_serves
    @for_sales = Serve.for_sale.where.not(id: cart_item_serves.map(&:serve_id).uniq)
    @for_sales.map do |serve|
      self.serve.get_charge(serve)
    end.compact
  end

  def same_cart_items
    if self.user_id
      CartItem.where(buyer_id: self.user_id).valid
    else
      CartItem.where(session_id: self.session_id).valid
    end
  end

  def total
    relation = CartItem.where(id: self.id)
    SummaryService.new(relation, buyer_id: self.buyer_id)
  end

  def self.checked_items(user_id: nil, buyer_id: nil, session_id: nil, myself: nil, extra: {})
    if user_id
      @checked_items = CartItem.default_where(user_id: user_id, myself: myself).pending.checked
      buyer_id = User.find(user_id).buyer_id
      puts "-----> Checked User: #{user_id}"
    elsif buyer_id
      @checked_items = CartItem.default_where(buyer_id: buyer_id, myself: myself).pending.checked
      puts "-----> Checked Buyer: #{buyer_id}"
    elsif session_id
      @checked_items = CartItem.default_where(session_id: session_id, myself: myself).pending.checked
      puts "-----> Checked Session: #{session_id}"
    else
      @checked_items = CartItem.none
      puts "-----> Checked None!"
    end
    SummaryService.new(@checked_items, buyer_id: buyer_id, extra: extra)
  end

  def self.extra
    {}
  end

  def self.good_types
    CartItem.select(:good_type).distinct.pluck(:good_type)
  end

end
