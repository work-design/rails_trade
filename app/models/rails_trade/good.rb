module RailsTrade::Good
  extend ActiveSupport::Concern
  
  included do
    attribute :name, :string
    attribute :sku, :string, default: -> { SecureRandom.hex }
    attribute :price, :decimal, default: 0
    attribute :currency, :string
    attribute :advance_payment, :decimal, default: 0
    attribute :extra, :json, default: {}
    attribute :unit, :string
    attribute :quantity, :decimal, default: 0
    attribute :unified_quantity, :decimal, default: 0
    
    has_many :cart_items, as: :good, autosave: true, dependent: :destroy
    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items

    has_many :promote_goods, as: :good
  end

  def name_detail
    "#{name}-#{id}"
  end
  
  def final_price
    compute_order_amount
    #self.retail_price + self.promote_price
  end

  def order_done
    puts 'Should realize in good entity'
  end

  def available_promote_ids
    ids = PromoteGood.available.where(good_type: self.class.base_class.name, good_id: [nil, self.id]).pluck(:promote_id)
    un_ids = self.promote_goods.unavailable.pluck(:promote_id)
    ids - un_ids
  end

  def available_promotes_with_buyer(buyer)
    ids = (available_promote_ids & buyer.all_promote_ids) - buyer.promote_buyers.unavailable.pluck(:promote_id)
    Promote.where(id: ids)
  end

  def compute_order_amount(user: nil, buyer: nil, **params)
    o = generate_order(user: user, buyer: buyer, **params)
    o.amount
  end

  def generate_order!(user: nil, buyer: nil, **params)
    o = generate_order(user: user, buyer: buyer, **params)
    o.check_state
    o.save!
    o
  end

  def generate_order(user: nil, buyer: nil, **params)
    if buyer
      o = buyer.orders.build
    elsif user
      o = user.orders.build
      cart = user.carts.default
      if cart
        o.buyer = cart.buyer
      end
    else
      o = Order.new
    end

    o.currency = self.currency
    o.organ_id = self.organ_id if self.respond_to?(:organ_id)

    number = params.delete(:number) || 1
    amount = params.delete(:amount) || number * self.price.to_d
    extra = params.delete(:extra) || {}
    good_name = params.delete(:name) || self.name

    oi = o.order_items.build(
      good: self,
      number: number,
      original_price: amount,
      extra: extra,
      good_name: good_name
    )

    promote_buyer_ids = Array(params.delete(:promote_buyer_ids))
    oi.compute_promote(promote_buyer_ids)
    oi.compute_sum

    o.assign_attributes params
    o.compute_sum
    o.extra = extra
    o
  end

end
