class OrderItem < ApplicationRecord

  attribute :cart_item_id, :integer
  attribute :good_type, :string
  attribute :good_id, :integer

  attribute :quantity, :decimal
  attribute :number, :integer, default: 1
  attribute :amount, :decimal, default: 0
  attribute :promote_sum, :decimal, default: 0
  attribute :serve_sum, :decimal, default: 0
  attribute :comment, :string
  attribute :advance_payment, :decimal, precision: 10, scale: 2
  attribute :extra, :json, default: {}

  belongs_to :order, autosave: true, inverse_of: :order_items
  belongs_to :cart_item, optional: true, autosave: true
  belongs_to :good, polymorphic: true, optional: true
  belongs_to :provider, optional: true
  has_many :order_promotes, autosave: true
  has_many :order_serves, autosave: true
  has_many :serves, through: :order_serves

  after_initialize if: :new_record? do |oi|
    init_from_cart_item if cart_item
  end
  after_update_commit :sync_amount, if: -> { saved_change_to_amount? }

  def compute_promote(promote_buyer_ids = nil)
    order.buyer.promote_buyers.where(id: Array(promote_buyer_ids)).each do |promote_buyer|
      self.order_promotes.build(promote_buyer_id: promote_buyer.id, promote_id: promote_buyer.promote_id)
    end

    good.overall_promotes.each do |promote|
      self.order_promotes.build(promote_id: promote.id)
    end
  end

  def compute_serve(serve_ids)
    Serve.single.overall.default
  end

  def valid_sum
    compute_sum

    if self.cart_item && self.amount != cart_item.final_price
      self.errors.add :base, 'Amount is not equal to cart items'
    end
  end

  def compute_sum
    self.serve_sum = self.order_serves.sum(&:amount)
    self.promote_sum = self.order_promotes.sum(&:amount)
    self.amount = self.original_price + self.serve_sum + self.promote_sum
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

  def init_from_cart_item
    self.assign_attributes cart_item.attributes.slice(:good_type, :good_id, :number, :buyer_type, :buyer_id, :pure_price, :extra)
    #self.advance_payment = self.good.advance_payment if self.advance_payment.to_f.zero?

    cart_item.serve_charges.each do |serve_charge|
      op = self.order_serves.build(serve_charge_id: serve_charge.id, serve_id: serve_charge.serve_id, amount: serve_charge.subtotal)
      op.order = self.order
    end

    cart_item.status = 'ordered'
  end

end unless RailsTrade.config.disabled_models.include?('OrderItem')
