module RailsTradeGood
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :sku, :string, default: -> { SecureRandom.hex }
    attribute :price, :decimal, default: 0
    attribute :currency, :string
    attribute :advance_payment, :decimal, default: 0
    attribute :extra, :json, default: {}
    thread_mattr_accessor :class_extra, instance_accessor: false

    has_many :cart_items, as: :good, autosave: true, dependent: :destroy

    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items

    has_many :promote_goods, as: :good

    RailsTrade.good_classes << self.name unless RailsTrade.good_classes.include?(self.name)
  end

  def extra
    Hash(self.class_extra).merge(extra)
  end

  def name_detail
    "#{name}-#{id}"
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

  def all_serves
    Serve.default_where('serve_goods.good_type': self.class.name, 'serve_goods.good_id': [nil, self.id])
  end

  def overall_promote_ids
    except_ids = self.promote_goods.kind_except.pluck(:promote_id)
    only_ids = self.promote_goods.kind_only.pluck(:promote_id)

    overall_promote_ids = Promote.overall_buyers.overall_goods.where.not(id: except_ids).pluck(:id)
    special_promote_ids = Promote.overall_buyers.special_goods.where(id: only_ids).pluck(:id)

    overall_promote_ids + special_promote_ids
  end

  def overall_promotes
    Promote.where(id: overall_promote_ids)
  end

  def buyer_promote_ids(buyer)
    unused_promote_ids = buyer.promote_buyers.unused.pluck(:promote_id)
    except_ids = self.promote_goods.kind_except.pluck(:promote_id)
    only_ids = self.promote_goods.kind_only.pluck(:promote_id)

    all_promote_ids = Promote.special_buyers.overall_goods.where(id: unused_promote_ids).where.not(id: except_ids).pluck(:id)
    special_promote_ids = Promote.special_buyers.special_goods.where(id: unused_promote_ids).where(id: only_ids).pluck(:id)

    all_promote_ids + special_promote_ids
  end

  def buyer_promotes(buyer)
    Promote.where id: buyer_promote_ids(buyer)
  end

  def apply_promotes(buyer, promote_buyer_ids = nil)
    overall_promote_ids

    return Promote.none unless promote_buyer_id
    select_promote_ids = PromoteBuyer.where(id: Array(promote_buyer_ids)).pluck(:promote_id)
    promotes = all_promotes.where(id: p)
    promotes.each do |promote|
      if promote.id == p.first&.promote_id
        promote.promote_buyer_id = promote_buyer_id
      end
    end
    promotes
  end

  def compute_order_amount(buyer, params = {})
    o = generate_order(buyer, params)
    o.amount
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

    number = params.delete(:number) || 1
    amount = params.delete(:amount) || number * self.price.to_d
    extra = params.delete(:extra)
    good_name = params.delete(:name) || self.name

    oi = o.order_items.build(
      good: self,
      number: number,
      original_price: amount,
      extra: extra,
      good_name: good_name
    )

    promote_buyer_ids = Array(params.delete(:promote_buyer_ids))
    serve_ids = Array(params.delete(:serve_ids))
    oi.compute_promote(promote_buyer_ids)
    oi.compute_serve(serve_ids)

    o.assign_attributes params
    o.compute_sum
    o
  end

end
