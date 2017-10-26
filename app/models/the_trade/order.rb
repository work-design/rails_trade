class Order < ApplicationRecord
  include ThePayment
  include TheRefund

  belongs_to :payment_strategy, optional: true
  belongs_to :buyer
  has_many :payment_orders, inverse_of: :order, dependent: :destroy
  has_many :payments, through: :payment_orders
  has_many :order_items, dependent: :destroy, autosave: true
  has_many :refunds, dependent: :nullify

  accepts_nested_attributes_for :order_items

  scope :credited, -> { where(payment_strategy_id: PaymentStrategy.where.not(period: 0).pluck(:id)) }


  after_initialize if: :new_record? do |o|
    self.uuid = UidHelper.nsec_uuid('OD')
  end

  enum payment_status: {
    unpaid: 0,
    part_paid: 1,
    all_paid: 2,
    refunding: 3,
    refunded: 4
  }
  enum payment_type: {
    paypal: 'paypal',
    alipay: 'alipay',
    stripe: 'stripe'
  }

  def migrate_from_cart_items(params)
    cart_item_ids = params[:cart_item_ids].split(',')
    cart_items = CartItem.where(id: cart_item_ids)
    cart_items.each do |cart_item|
      self.order_items.build cart_item_id: cart_item.id, good_type: cart_item.good_type, good_id: cart_item.good_id, quantity: cart_item.quantity
    end
  end

end
