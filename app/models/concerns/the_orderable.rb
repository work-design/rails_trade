module TheOrderable
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, optional: true
    has_many :payment_orders, dependent: :destroy
    has_many :payments, through: :payment_orders
  end

  def unreceived_amount
    self.amount - self.received_amount
  end

  def pending_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

end
