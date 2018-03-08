module OrderAble
  extend ActiveSupport::Concern
  include GoodAble

  included do
    has_one :order_item, as: :good, dependent: :nullify
    has_one :order, through: :order_item
  end

  def update_order
    order_item.update amount: self.price
  end

  def get_order
    return @order if @order
    @order = self.order || generate_order(self.user, { number: 1 })
  end

  def generate_order(user, params = {})
    o = user.orders.build
    o.buyer_id = user.buyer_id if user.buyer_id
    o.currency = self.currency

    oi = o.order_items.build
    oi.good = self
    if params[:number].to_i > 0
      oi.number = params[:number]
    else
      oi.number = 1
    end

    if params[:amount]
      oi.amount = params[:amount]
    else
      oi.amount = oi.number * self.price.to_d
    end
    
    o.amount = oi.amount

    self.class.transaction do
      o.check_state
      o.save!
      oi.save!
    end
    o
  end

end