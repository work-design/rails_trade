module GoodAble
  extend ActiveSupport::Concern

  included do
    attribute :import_price, :decimal
    attribute :profit_price, :decimal
    attribute :price, :decimal
    attribute :advance_payment, :decimal
    attribute :sku, :string, default: 'item'

    has_many :cart_items, as: :good, autosave: true, dependent: :destroy
    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items
    has_many :promote_goods, as: :good
    has_many :promotes, through: :promote_goods
    has_many :null_promote_goods, -> { self.or(PromoteGood.where(good_id: nil)) }, class_name: 'PromoteGood', as: :good
    has_many :null_promotes, through: :null_promote_goods, source: :promote

    composed_of :serve,
                class_name: 'ServeFee',
                mapping: ['id', 'good_id'],
                constructor: Proc.new { |id| ServeFee.new(self.name, id, 1, nil, self.extra) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [['id', 'good_id']],
                constructor: Proc.new { |id| PromoteFee.new(self.name, id) }
    before_save :sync_price

    def self.extra
      {}
    end
  end

  def extra
    {}
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

  def sync_price
    self.price = self.import_price.to_d + self.profit_price.to_d
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

# required attributes

# sku
# price
# import_price
# profit_price
# advance_payment

# t.integer  "provider_id", limit: 4
# t.string   "sku",         limit: 255
# t.float    "price",       limit: 24,    default: 9999.0
# t.integer  "sales_count", limit: 4,     default: 0
# t.boolean  "published",   limit: 1,     default: true
# t.integer  "promote_id",  limit: 4
