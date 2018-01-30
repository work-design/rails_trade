module OrderAble
  extend ActiveSupport::Concern
  include GoodAble

  included do
    has_one :order_item, as: :good, dependent: :nullify
    has_one :order, -> { where(payment_status: [:unpaid, :part_paid, :all_paid]) }, through: :order_item
  end

  def get_order
    return @order if @order
    @order = self.order || generate_order(self.user, { quantity: 1 })
  end

  def generate_order(user, params = {})
    o = user.orders.build
    o.buyer_id = user.buyer_id

    oi = o.order_items.build
    oi.good = self
    if params[:quantity].to_i > 0
      oi.quantity = params[:quantity]
    else
      oi.quantity = 1
    end

    if params[:amount]
      oi.amount = params[:amount]
    else
      oi.amount = oi.quantity * self.price.to_d
    end

    o.currency = self.currency

    self.class.transaction do
      o.check_state
      o.save!
      oi.save!
    end
    o
  end

end