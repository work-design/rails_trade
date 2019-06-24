module RailsTrade::OrderItem
  extend ActiveSupport::Concern
  include RailsTrade::PriceModel
  include RailsTrade::PricePromote

  included do
    attribute :cart_item_id, :integer
    
    attribute :note, :string
    attribute :advance_payment, :decimal, default: 0
    attribute :extra, :json, default: {}
  
    belongs_to :order, autosave: true, inverse_of: :order_items
    belongs_to :cart_item, optional: true, autosave: true
    belongs_to :good, polymorphic: true, optional: true
    belongs_to :provider, optional: true
    has_many :entity_promotes, -> { includes(:promote) }, as: :item, autosave: true, dependent: :destroy
  
    after_initialize :sync_from_cart_item, if: :new_record?
    after_save :sync_order_amount, if: -> { saved_change_to_amount? }
  end

  def valid_sum
    compute_amount

    if self.cart_item && self.amount != cart_item.final_price
      self.errors.add :base, 'Amount is not equal to cart items'
    end
  end

  def compute_amount
    compute_amount_items
  end

  def sync_order_amount
    order.compute_amount
    order.save
  end

  def confirm_ordered!
    self.good.order_done
  end

  def confirm_paid!

  end

  def confirm_part_paid!

  end

  def confirm_refund!

  end

  def sync_from_cart_item
    if cart_item
      self.assign_attributes cart_item.attributes.slice(:good_type, :good_id, :number, :buyer_type, :buyer_id, :pure_price, :extra)
      self.advance_payment = self.good.advance_payment if self.advance_payment.zero?

      cart_item.status = 'ordered'
    end
  end
  
  def xx
    cart_item.entity_promotes.update_all(entity_type: 'Order', entity_id: self.order_id, item_type: 'OrderItem', item_id: self.id)
  end

end
