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

  def all_promotes(buyer = nil)
    except_ids = PromoteGood.kind_except.where(good_id: self.id).pluck(:promote_id)
    overall_good_ids = Promote.overall_buyers.overall_goods.where.not(id: except_ids).pluck(:id)

    only_ids = PromoteGood.kind_only.where(good_id: self.id).pluck(:promote_id)
    special_good_ids = Promote.overall_buyers.special_goods.where(id: only_ids).pluck(:id)

    all_ids = overall_good_ids + special_good_ids
    if buyer
      buyer_ids = buyer.promote_buyers.pluck(:promote_id)
      all_buyer_ids = Promote.special_buyers.overall_goods.where(id: buyer_ids).where.not(id: except_ids).pluck(:id)
      special_buyer_ids = Promote.special_buyers.special_goods.where(id: buyer_ids).where(id: only_ids).pluck(:id)
      all_ids += all_buyer_ids + special_buyer_ids
    end

    Promote.where(id: all_ids)
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
