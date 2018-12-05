class Payment < ApplicationRecord
  include Auditable
  extend RailsRoleOwner

  attribute :type, :string, default: 'HandPayment'
  attribute :currency, :string, default: RailsTrade.config.default_currency
  attribute :adjust_amount, :decimal, default: 0

  belongs_to :payment_method, optional: true
  has_many :payment_orders, dependent: :destroy
  has_many :orders, through: :payment_orders, inverse_of: :payments

  default_scope -> { order(created_at: :desc) }

  # validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0, equal_to: ->(o) { o.income_amount + o.fee_amount.to_d } }
  #validates :checked_amount, numericality: { greater_than_or_equal_to: 0, equal_to: ->(o) { o.total_amount + o.adjust_amount } }
  validates :payment_uuid, uniqueness: { scope: :type }

  before_save :compute_amount
  after_create :analyze_payment_method

  has_one_attached :proof

  after_initialize if: :new_record? do |o|
    self.payment_uuid ||= UidHelper.nsec_uuid('PAY')
  end

  enum state: {
    init: 'init',
    part_checked: 'part_checked',
    all_checked: 'all_checked',
    adjust_checked: 'adjust_checked',
    abusive_checked: 'abusive_checked'
  }

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
    total_amount.to_d - payment_orders.sum(&:check_amount).to_d
  end

  def compute_amount
    if income_amount.blank? && fee_amount.present?
      self.income_amount = self.total_amount - self.fee_amount
    end

    if fee_amount.blank? && income_amount.present?
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
    self.adjust_amount = self.checked_amount.to_d - self.total_amount.to_d
    self.state = 'all_checked'
    self.save
  end

  def check_order(order_id)
    order = Order.find order_id
    payment_order = self.payment_orders.build(order_id: order.id)
    payment_order.check_amount = order.unreceived_amount
    payment_order.save

    payment_order
  end

  def check_state
    if self.checked_amount.to_d == self.total_amount
      self.state = 'all_checked'
    elsif self.checked_amount.to_d == 0
      self.state = 'init'
    elsif self.checked_amount.to_d < self.total_amount
      self.state = 'part_checked'
    elsif self.checked_amount > self.total_amount
      self.state = 'adjust_checked'
    else
      self.state = 'abusive_checked'
    end
  end

  def check_state!
    self.check_state
    self.save!
  end

  def self.total_amount_step
    0.1.to_d.power(Payment.columns_hash['total_amount'].scale)
  end

end unless RailsTrade.config.disabled_models.include?('Payment')

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
