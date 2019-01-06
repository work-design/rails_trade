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

    composed_of :serve,
                class_name: 'ServeFee',
                mapping: [
                  ['id', 'good_id'],
                  ['extra', 'extra']
                ],
                constructor: Proc.new { |id, extra| ServeFee.new(self.name, id, extra: Hash(self.class_extra).merge(extra)) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [
                  ['id', 'good_id'],
                  ['extra', 'extra']
                ],
                constructor: Proc.new { |id, extra| PromoteFee.new(self.name, id, extra: Hash(self.class_extra).merge(extra)) }
    RailsTrade.good_classes << self.name unless RailsTrade.good_classes.include?(self.name)
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

  def all_promotes
    except_ids = PromoteGood.kind_except.where(good_id: self.id).pluck(:promote_id)
    overalls = Promote.overall_goods.where.not(id: except_ids)

    only_ids = PromoteGood.kind_except.where(good_id: self.id).pluck(:promote_id)
    specials = Promote.special_goods.where(id: only_ids)

    overalls + specials
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
      pure_price: amount,
      buyer_type: buyer.class.name,
      buyer_id: buyer.id,
      extra: extra,
      good_name: good_name
      #promote_buyer_id: params.delete(:promote_buyer_id)
    )

    oi.compute_promote_and_serve
    o.assign_attributes params
    o.compute_sum
    o
  end

end
