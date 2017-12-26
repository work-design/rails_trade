module GoodAble
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, as: :good, autosave: true, dependent: :destroy
    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items

    composed_of :serve,
                class_name: 'ServeFee',
                mapping: ['id', 'good_id'],
                constructor: Proc.new { |id| ServeFee.new(self.name, id) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [['id', 'good_id']],
                constructor: Proc.new { |id| PromoteFee.new(self.name, id) }

    after_commit :reset_payment_status, on: [:create, :update]
  end

  def reset_payment_status
    self.payment_status =
     self.orders.sum(:amount) == self.orders.sum(:received_amount) ? true : false
  end

  def retail_price
    self.price.to_d + self.serve.subtotal
  end

  def final_price
    self.retail_price + self.promote.subtotal
  end

  def order_done
    puts 'Should realize in good entity'
  end

  def get_cart_item(user, params = {})
    self.cart_items.find_or_create_by(params.merge(user: user))
  end

  def generate_order(buyer, params)
    o = buyer.orders.build
    o.user_id = buyer.user_id
    o.buyer_id = buyer.id

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
    if o.amount == 0
      o.payment_status = 'all_paid'
    else
      o.payment_status = 'unpaid'
    end

    self.class.transaction do
      o.save!
      oi.save!
      if o.amount == 0
        o.check_state!
        o.confirm_paid!
      end
    end
    o
  end
  alias_method :get_order, :generate_order

end

# required attributes

# sku
# price


# t.integer  "provider_id", limit: 4
# t.string   "sku",         limit: 255
# t.float    "price",       limit: 24,    default: 9999.0
# t.integer  "sales_count", limit: 4,     default: 0
# t.boolean  "published",   limit: 1,     default: true
# t.integer  "promote_id",  limit: 4
