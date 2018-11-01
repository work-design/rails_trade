module RailsTradeOrder
  extend ActiveSupport::Concern
  include RailsTradeGood

  included do
    belongs_to :buyer, polymorphic: true, optional: true
    has_one :order_item, as: :good, dependent: :nullify
    has_one :order, ->(o){ where(buyer_type: o.buyer.class.name, buyer_id: o.buyer.id) }, through: :order_item
  end

  def update_order
    order_item.update amount: self.price
  end

  def get_order(buyer)
    return @order if @order
    @order = self.order || generate_order(buyer, { number: 1 })
  end

  def generate_order!(buyer, params = {})
    o = generate_order(buyer, params)
    o.check_state
    o.save!
    o
  end

  def generate_order(buyer, params = {})
    o = buyer.orders.build
    o.currency = self.currency

    oi = o.order_items.build
    oi.good = self
    if params[:number].to_i > 0
      oi.number = params.delete(:number)
    else
      oi.number = 1
    end

    if params[:amount]
      oi.amount = params.delete(:amount)
    else
      oi.amount = oi.number * self.price.to_d
    end

    o.assign_attributes params
    o.amount = oi.amount
    o
  end

end
