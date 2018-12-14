class CartItem < ApplicationRecord
  include ServeAndPromote

  attribute :status, :string, default: 'init'
  attribute :number, :integer, default: 1
  serialize :extra, Hash

  belongs_to :buyer, polymorphic: true, optional: true
  belongs_to :good, polymorphic: true
  has_many :cart_item_serves, -> { includes(:serve) }, dependent: :destroy
  has_many :order_items, dependent: :nullify

  scope :valid, -> { where(status: 'pending', myself: true) }
  scope :checked, -> { where(status: 'pending', checked: true) }

  enum status: {
    init: 'init',
    pending: 'pending',
    ordered: 'ordered',
    deleted: 'deleted'
  }

  validates :buyer_id, presence: true, if: -> { session_id.blank? }
  validates :session_id, presence: true, if: -> { buyer_id.blank?  }

  def total_quantity
    good.unified_quantity.to_d * self.number
  end

  # 零售价
  def retail_price
    self.good.retail_price * self.number
  end

  def discount_price
    bulk_price - retail_price
  end

  # 商品原价
  def pure_price
    good.price.to_d * number
  end

  # 附加服务价格汇总
  def serve_price
    serve_charges.sum(&:subtotal)
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
    total_serve_charges.sum(&:subtotal)
  end

  def total_promote_price
    total.promote_charges.sum(&:subtotal)
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
    if self.buyer_id
      CartItem.where(buyer_type: self.buyer_type, buyer_id: self.buyer_id).valid
    else
      CartItem.where(session_id: self.session_id).valid
    end
  end

  def total
    relation = CartItem.where(id: self.id)
    SummaryService.new(relation, buyer_type: self.buyer_type, buyer_id: self.buyer_id, extra: self.extra)
  end

  def self.checked_items(buyer_type: nil, buyer_id: nil, session_id: nil, myself: nil, extra: self.extra)
    if buyer_id
      @checked_items = CartItem.default_where(buyer_type: buyer_type, buyer_id: buyer_id, myself: myself).pending.checked
      puts "-----> Checked Buyer: #{buyer_id}"
    elsif session_id
      @checked_items = CartItem.default_where(session_id: session_id, myself: myself).pending.checked
      puts "-----> Checked Session: #{session_id}"
    else
      @checked_items = CartItem.none
      puts "-----> Checked None!"
    end
    SummaryService.new(@checked_items, buyer_type: buyer_type, buyer_id: buyer_id, extra: extra)
  end

  def self.good_types
    CartItem.select(:good_type).distinct.pluck(:good_type)
  end

end unless RailsTrade.config.disabled_models.include?('CartItem')
