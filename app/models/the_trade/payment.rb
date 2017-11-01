class Payment < ApplicationRecord
  include Auditable

  attribute :currency, :string, default: 'USD'

  belongs_to :payment_method, optional: true
  has_many :payment_orders, dependent: :destroy, inverse_of: :payment
  has_many :orders, through: :payment_orders

  default_scope -> { order(created_at: :desc) }

  validates :total_amount, numericality: { equal_to: -> (o) { o.income_amount + o.fee_amount } }, if: -> { income_amount.present? && fee_amount.present? && total_amount.present? }
  validates :adjust_amount, numericality: { less_than: 1, greater_than: -1 }, allow_blank: true

  before_save :compute_amount
  after_create :analyze_payment_method

  enum state: [
    :init,
    :part_checked,
    :all_checked,
    :abusive_checked
  ]

  def analyze_payment_method
    if self.buyer_name.present? || self.buyer_identifier.present?
      pm = PaymentMethod.find_or_initialize_by(account_name: self.buyer_name.to_s, account_num: self.buyer_identifier.to_s)
      pm.bank = self.buyer_bank
      self.payment_method = pm

      pm.save
      self.save
    end
  end

  def unchecked_amount
    total_amount.to_d - pending_checked_amount.to_d
  end

  def pending_checked_amount
    PaymentOrder.where(payment_id: self.id).sum(:check_amount)
  end

  def compute_amount
    if total_amount.blank? && fee_amount.present? && income_amount.present?
      self.total_amount = self.fee_amount + self.income_amount
    end

    if income_amount.blank? && total_amount.present? && fee_amount.present?
      self.income_amount = self.total_amount - self.fee_amount
    end

    if fee_amount.blank? && total_amount.present? && income_amount.present?
      self.fee_amount = self.total_amount - self.income_amount
    end
    self.check_state
  end

  def pending_orders
    if self.payment_method
      buyer_ids = self.payment_method.payment_references.pluck(:buyer_id)
      Order.where.not(id: self.payment_orders.pluck(:order_id)).where(buyer_id: buyer_ids, payment_status: ['unpaid', 'part_paid'], state: 'active')
    else
      []
    end
  end

  def analyze_adjust_amount
    self.adjust_amount = init_adjust_amount
    self.state = 'all_checked'
    self.save
  end

  def init_adjust_amount
    self.checked_amount.to_d - self.total_amount.to_d
  end

  def check_order(order_id)
    order = Order.find order_id
    payment_order = self.payment_orders.build(order_id: order.id)
    payment_order.check_amount = order.unreceived_amount
    payment_order.save

    payment_order
  end

  def check_state
    if checked_amount.to_d >= total_amount
      self.state = 'all_checked'
      self.adjust_amount = self.checked_amount.to_d - self.total_amount
    elsif self.checked_amount.to_d > 0 && self.checked_amount.to_d < self.total_amount
      self.state = 'part_checked'
    elsif self.checked_amount.to_d == 0
      self.state = 'init'
    else
      self.state = 'abusive_checked'
    end
  end

  def check_state!
    self.check_state
    self.save!
  end

end

#  :id, :integer, limit: 4, null: false
#  :type, :string, limit: 255
#  :total_amount, :decimal, precision: 10, scale: 2
#  :order_amount, :decimal, precision: 10, scale: 2
#  :fee_amount, :decimal, precision: 10, scale: 2
#  :payment_uuid, :string, limit: 255
#  :notify_type, :string, limit: 255
#  :notified_at, :datetime, precision: 0
#  :pay_status, :string, limit: 255
#  :buyer_email, :string, limit: 255
#  :sign, :string, limit: 255
#  :seller_identifier, :string, limit: 255
#  :buyer_identifier, :string, limit: 255
#  :user_id, :integer, limit: 4
#  :currency, :string, limit: 255
#  :state, :integer, limit: 4, default: 0
#  :created_at, :datetime, precision: 0, null: false
#  :updated_at, :datetime, precision: 0, null: false