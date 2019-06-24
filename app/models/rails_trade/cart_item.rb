module RailsTrade::CartItem
  extend ActiveSupport::Concern
  include RailsTrade::PricePromote
  include RailsTrade::PriceModel

  included do
    attribute :status, :string, default: 'init'
    attribute :myself, :boolean, default: true
    attribute :extra, :json, default: {}

    attribute :retail_price, :decimal, default: 0  # 单个商品零售价(商品原价 + 服务价)
    attribute :wholesale_price, :decimal, default: 0  # 多个商品批发价
    
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
  
  def compute_amount
    compute_amount_items
    
    self.retail_price = single_price + additional_price
    self.wholesale_price = original_price + additional_price
  end

  def migrate_to_order
    self.buyer = cart_item.buyer
    o = Order.new
    oi = o.order_items.build(cart_item_id: cart_item_id)
  
    self.entity_promotes.each do |entity_promote|
      entity_promote.entity = o
      entity_promote.item = oi
    end
    o
  end
  
  class_methods do
    
    def good_types
      CartItem.select(:good_type).distinct.pluck(:good_type)
    end
    
  end

end
