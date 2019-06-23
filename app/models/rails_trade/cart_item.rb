module RailsTrade::CartItem
  extend ActiveSupport::Concern
  include RailsTrade::PricePromote
  include RailsTrade::PriceModel

  included do
    attribute :status, :string, default: 'init'
    attribute :myself, :boolean, default: true
    attribute :quantity, :decimal
    attribute :reduced_price, :decimal, default: 0
    attribute :extra, :json, default: {}

    belongs_to :good, polymorphic: true
    belongs_to :cart, counter_cache: true
    has_many :entity_promotes, -> { includes(:promote) }, as: :item, dependent: :destroy
    has_many :order_items, dependent: :nullify

    scope :valid, -> { where(status: 'init', myself: true) }
    scope :checked, -> { where(status: 'init', checked: true) }
    
    enum status: {
      init: 'init',
      ordered: 'ordered',
      deleted: 'deleted'
    }

    before_validation :sync_amount
    after_commit :sync_cart_charges, :total_cart_charges, if: -> { number_changed? }, on: [:create, :update]
  end

  def origin_quantity
    good.unified_quantity * self.number
  end

  # 批发价和零售价之间的差价，即批发折扣
  def discount_price
    bulk_price - retail_price
  end

  def sync_amount
    self.single_price = good.price
    self.original_price = good.price * number
    
    self.retail_price = single_price + serve_price
    self.bulk_price = original_price + serve_price
    
    self.serve_price = cart_promotes.select { |cp| cp.amount >= 0 }.sum(&:amount)
    self.reduced_price = cart_promotes.select { |cp| cp.amount < 0 }.sum(&:amount)  # 促销价格

    self.amount = self.bulk_price + self.reduced_price  # 最终价格
  end

  def migrate_to_order
    self.buyer = cart_item.buyer
    o = Order.new
    o.order_items.build(cart_item_id: cart_item_id)
  end
  
  class_methods do
    
    def good_types
      CartItem.select(:good_type).distinct.pluck(:good_type)
    end
    
  end

end
