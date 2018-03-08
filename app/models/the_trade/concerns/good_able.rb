module GoodAble
  extend ActiveSupport::Concern

  included do
    attribute :import_price, :decimal, default: 0
    attribute :profit_price, :decimal, default: 0
    attribute :price, :decimal, default: 0
    attribute :advance_payment, :decimal, default: 0
    attribute :sku, :string, default: 'item'
    attribute :currency, :string
    
    has_many :cart_items, as: :good, autosave: true, dependent: :destroy
    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items
    has_many :promote_goods, as: :good
    has_many :promotes, through: :promote_goods

    composed_of :serve,
                class_name: 'ServeFee',
                mapping: ['id', 'good_id'],
                constructor: Proc.new { |id| ServeFee.new(self.name, id, 1, nil, self.extra) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [['id', 'good_id']],
                constructor: Proc.new { |id| PromoteFee.new(self.name, id) }
    before_save :sync_price, if: -> { import_price_changed? || profit_price_changed? }

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

  def all_serves
    Serve.default_where('serve_goods.good_type': self.class.name, 'serve_goods.good_id': [nil, self.id])
  end

  def all_promotes
    Promote.default_where('promote_goods.good_type': self.class.name, 'promote_goods.good_id': [nil, self.id])
  end

  private
  def sync_price
    self.price = self.import_price.to_d + self.profit_price.to_d
  end

end