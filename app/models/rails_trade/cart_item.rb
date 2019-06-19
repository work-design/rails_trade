module RailsTrade::CartItem
  extend ActiveSupport::Concern
  included do
    include RailsTrade::PriceModel

    attribute :status, :string, default: 'init'
    attribute :myself, :boolean, default: true
    attribute :quantity
    attribute :reduced_price, :decimal, default: 0
    attribute :extra, :json

    belongs_to :good, polymorphic: true
    belongs_to :cart, counter_cache: true
    has_many :cart_promotes, -> { includes(:promote) }, dependent: :destroy
    has_many :order_items, dependent: :nullify

    scope :valid, -> { where(status: 'pending', myself: true) }
    scope :checked, -> { where(status: 'pending', checked: true) }
    
    enum status: {
      init: 'init',
      ordered: 'ordered',
      deleted: 'deleted'
    }

    before_validation :sync_amount
    after_commit :sync_cart_charges, :total_cart_charges, if: -> { number_changed? }, on: [:create, :update]
  end

  def total_quantity
    good.unified_quantity.to_d * self.number
  end

  # 批发价和零售价之间的差价，即批发折扣
  def discount_price
    bulk_price - retail_price
  end

  def final_price
    self.bulk_price + self.reduced_price
  end

  def total_serve_price
    total.serve_charges.sum(:amount)
  end

  def total_promote_price
    total.promote_charges.sum(:amount)
  end

  def estimate_price
    final_price + total_serve_price + total_promote_price
  end

  def sync_amount
    self.single_price = good.price
    self.original_price = good.price * number
    
    self.single_serve_price = cart_serves.sum(:price)
    self.retail_price = single_price + serve_price
    self.serve_price = cart_serves.sum(:amount)
    self.bulk_price = original_price + serve_price

    self.reduced_price = -cart_promotes.sum(:amount)  # 促销价格

    self.amount = self.bulk_price + self.reduced_price  # 最终价格
  end

  def sync_cart_charges
    QuantityPromote.overall.each do |promote|
      charge = promote.compute_charge(quantity)
      self.cart_serves.build(promote_charge_id: charge.id, original_amount: charge.final_price(quantity))
    end

    NumberPromote.overall.each do |promote|
      charge = promote.compute_charge(number)
      self.cart_promotes.build(promote_charge_id: charge.id, amount: charge.final_price(number))
    end
  end

  def total_cart_charges
    total.serve_charges.each do |charge|
      cart_serve = self.cart_serves.build(serve_charge_id: charge.id, original_amount: charge.subtoal, scope: 'total')
      cart_serve.save
    end

    total.promote_charges.each do |charge|
      cart_promote = self.cart_promotes.build(promote_charge_id: charge.id, amount: charge.subtoal, scope: 'total')
      cart_promote.save
    end
  end

  def for_select_serves
    @for_sales = Serve.for_sale.where.not(id: cart_serves.map(&:serve_id).uniq)
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
    return @total if defined?(@total)
    @total = CartService.new(cart_item_id: self.id, extra: self.extra)
  end
  
  class_methods do
    
    def good_types
      CartItem.select(:good_type).distinct.pluck(:good_type)
    end
    
  end

end
