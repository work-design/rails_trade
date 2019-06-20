module RailsTrade::OrderItem
  extend ActiveSupport::Concern
  included do
    attribute :cart_item_id, :integer
    attribute :good_type, :string
    attribute :good_id, :integer
  
    attribute :quantity, :decimal
    attribute :number, :integer, default: 1
    attribute :good_sum, :decimal, default: 0
    attribute :promote_sum, :decimal, default: 0
    attribute :amount, :decimal, default: 0
    attribute :comment, :string
    attribute :advance_payment, :decimal, default: 0
    attribute :extra, :json, default: {}
  
    belongs_to :order, autosave: true, inverse_of: :order_items
    belongs_to :cart_item, optional: true, autosave: true
    belongs_to :good, polymorphic: true, optional: true
    belongs_to :provider, optional: true
    has_many :order_promotes, autosave: true
    has_many :promotes, through: :order_promotes
  
    after_initialize :init_from_cart_item, if: :new_record?
    after_update_commit :sync_amount, if: -> { saved_change_to_amount? }
  end
  
  def compute_promote(promote_buyer_ids = nil)
    all_ids = good.available_promote_ids & Promote.single.default.pluck(:id)
    
    if promote_buyer_ids.present?
      buyer_promotes = order.buyer.promote_buyers.where(id: Array(promote_buyer_ids))
      buyer_promotes.each do |promote_buyer|
        self.order_promotes.build(promote_buyer_id: promote_buyer.id, promote_id: promote_buyer.promote_id)
      end
      
      all_ids -= buyer_promotes.pluck(:promote_id)
    end

    all_ids.each do |promote_id|
      self.order_promotes.build(promote_id: promote_id)
    end
  end

  def valid_sum
    compute_sum

    if self.cart_item && self.amount != cart_item.final_price
      self.errors.add :base, 'Amount is not equal to cart items'
    end
  end

  def compute_sum
    self.promote_sum = order_promotes.select(&:single?).sum(&:amount)
    self.amount = self.good_sum + self.promote_sum
  end

  def sync_amount
    order.compute_sum
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

end
