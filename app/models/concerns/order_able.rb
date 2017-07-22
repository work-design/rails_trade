module OrderAble
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, polymorphic: true
    belongs_to :payment_strategy, optional: true

    has_many :payment_orders, dependent: :destroy
    has_many :payments, through: :payment_orders
    has_many :order_items, dependent: :destroy, autosave: true

    after_initialize if: :new_record? do |o|
      self.uuid = UidHelper.nsec_uuid('OD')
    end

    enum payment_status: {
      unpaid: 0,
      part_paid: 1,
      all_paid: 2,
      refunded: 3
    }
  end


  def unreceived_amount
    self.amount - self.received_amount
  end

  def init_received_amount
    self.payment_orders.sum(:check_amount)
  end

  def pending_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def exists_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).exists?(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

end


